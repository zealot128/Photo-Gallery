class MediaSearch
  include ActiveModel::Model
  include FilterFormModel
  attr_accessor :labels
  attr_accessor :from
  attr_accessor :to
  attr_accessor :type
  attr_accessor :person_ids
  attr_accessor :per_page
  attr_accessor :file_size
  attr_accessor :aperture
  attr_accessor :favorite

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
      d = date_parse(from)
      if d
        @parsed_from = d.to_date
        sql = sql.where('shot_at >= ?', @parsed_from)
      end
    end
    if to.present?
      d = date_parse(to)
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
      @file_size_min, @file_size_max = parsed(file_size)
      sql = sql.where('file_size >= ?', @file_size_min) if @file_size_min
      sql = sql.where('file_size <= ?', @file_size_max) if @file_size_max
    end
    if aperture.present?
      @aperture_min, @aperture_max = parsed(aperture)
      sql = sql.where('aperture is not null and aperture >= ?', @aperture_min) if @aperture_min
      sql = sql.where('aperture is not null and aperture <= ?', @aperture_max) if @aperture_max
    end
    if favorite == '1'
      sql = sql.where('(select 1 from likes where base_file_id = photos.id) is not null')
    end
    sql.order('shot_at desc').includes(:image_faces, :image_labels, :liked_by)
  end
end
