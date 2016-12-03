class MediaSearch
  include ActiveModel::Model
  attr_accessor :labels
  attr_accessor :from
  attr_accessor :to
  attr_accessor :type

  attr_reader :parsed_from, :parsed_to

  def label_facets
    ImageLabel.joins(:base_files).
      where('photos.id in (?)', media.select('photos.id')).
      order('count_all desc').group(:name).limit(100).count
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
    sql
  end
end
