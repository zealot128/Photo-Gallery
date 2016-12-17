class MediaSearch
  include ActiveModel::Model
  attr_accessor :labels
  attr_accessor :from
  attr_accessor :to
  attr_accessor :type
  attr_accessor :person_ids
  attr_accessor :per_page
  attr_accessor :file_size

  attr_reader :file_size_min, :file_size_max

  attr_reader :parsed_from, :parsed_to

  def label_facets
    ImageLabel.joins(:base_files).
      where('photos.id in (?)', media.select('photos.id')).
      order('count_all desc').group(:name).limit(100).count
  end

  def per_page=(val)
    @per_page = val.to_i
  end

  def type=(other)
    @type = other.reject(&:blank?)
  end

  def media
    sql = BaseFile.all
    if labels.present?
      l = labels.split(/ *[,;] */)
      aws_labels = ImageLabel.where('name ilike any (array[?])', l).pluck(:id)
      if aws_labels.any?
        sql = sql.where('photos.id in (?)',
                        BaseFile.joins(:image_labels).
                        where('image_labels.id in (?)', aws_labels).
                          select('photos.id')
                       )
      end
    end
    if type.present?
      allowed_types = []
      if type.include?('photos')
        allowed_types << 'Photo'
      end
      if type.include?('videos')
        allowed_types << 'Video'
      end
      sql = sql.where(type: allowed_types)
    end
    if from.present?
      d = Chronic.parse(from, context: :past)
      if d
        @parsed_from = d.to_date
        sql = sql.where('shot_at >= ?', @parsed_from)
      end
    end
    if to.present?
      d = Chronic.parse(to, context: :past)
      if d
        @parsed_to = d.to_date
        sql = sql.where('shot_at <= ?', @parsed_to)
      end
    end
    if person_ids.present? && (p=person_ids.reject(&:blank?)).any?
      people = Person.where(id: p)
      people.each do |person|
        sql = sql.where('photos.id in (?)', person.image_faces.select('image_faces.base_file_id')) if person.present?
      end
    end
    if file_size.present?
      @file_size_min, @file_size_max = parsed_file_size
      sql = sql.where('file_size >= ?', @file_size_min) if @file_size_min
      sql = sql.where('file_size <= ?', @file_size_max) if @file_size_max
    end
    sql.order('shot_at desc').includes(:image_faces, :image_labels)
  end

  def parsed_file_size
    return [nil, nil] if file_size.blank?

    min = nil
    max = nil

    parts = file_size.split(',').map(&:strip).reject(&:blank?)
    unit = "[\\d+,\\.kKmMgGbB ]+"
    parts.each do |part|
      case part
      when /^>=?(#{unit})/
        min = parse_number_with_unit($1)
      when /^<=?(#{unit})/
        max = parse_number_with_unit($1)
      when /^(#{unit})-(#{unit})/
        min = parse_number_with_unit($1)
        max = parse_number_with_unit($2)
      end
    end

    [ min, max]
  end

  def parse_number_with_unit(string)
    return nil if string.blank?
    string.gsub!(" ", "")
    string.gsub!(/bB/, "")
    multiplicator = 1
    multiplicator *= 1.kilobyte while string.sub!(/k/i,'')
    multiplicator *= 1.megabyte while string.sub!(/m/i,'')
    multiplicator *= 1.megabyte while string.sub!(/g/i,'')

    string.to_f * multiplicator
  end
end
