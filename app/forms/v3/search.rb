# rubocop:disable Style/ClassVars
class V3::Search
  class << self
    attr_accessor :filters
    def add_filter(column, array: false, &block)
      attr_accessor column
      if array
        define_method("#{column}=") { |val|
          instance_variable_set("@#{column}", val.try(:reject, &:blank?))
        }
      end
      self.filters ||= {}
      self.filters[column] = block
    end
  end

  include ActiveModel::Model
  include FilterFormModel
  attr_accessor :per_page
  attr_accessor :file_size
  attr_accessor :page
  attr_reader :file_size_min, :file_size_max
  attr_reader :parsed_from, :parsed_to

  def label_facets
    ImageLabel.joins(:base_files).
      where('photos.id in (?)', media.select('photos.id')).
      order('count_all desc').group(:name).limit(100).count
  end

  def page=(val)
    @page = val.to_i
  end

  def per_page=(val)
    @per_page = val.to_i
  end

  def file_types=(other)
    @file_types = other.reject(&:blank?)
  end

  def media
    sql = BaseFile.visible.
      order('shot_at desc').
      includes(:image_faces, :image_labels, :liked_by)
    self.class.filters.each do |column, filter|
      next if send(column).blank?
      new_sql = instance_exec(sql, &filter)
      sql = new_sql if new_sql
    end
    sql.paginate(page: page, per_page: 10)
  end

  add_filter(:favorite) do |sql|
    if favorite == 'true'
      sql.where('(select 1 from likes where base_file_id = photos.id) is not null')
    end
  end

  add_filter(:file_types, array: true) do |sql|
    return sql if file_types.blank?
    allowed_types = []
    if file_types.include?('photo')
      allowed_types << 'Photo'
    end
    if file_types.include?('video')
      allowed_types << 'Video'
    end
    sql.where(type: allowed_types)
  end

  add_filter(:aperture) do |sql|
    @aperture_min, @aperture_max = parsed(aperture)
    sql = sql.where('aperture is not null and aperture >= ?', @aperture_min) if @aperture_min
    sql = sql.where('aperture is not null and aperture <= ?', @aperture_max) if @aperture_max
    sql
  end

  add_filter(:file_size) do |sql|
    @file_size_min, @file_size_max = parsed(file_size)
    sql = sql.where('file_size >= ?', @file_size_min) if @file_size_min
    sql = sql.where('file_size <= ?', @file_size_max) if @file_size_max
    sql
  end

  add_filter(:people_ids, array: true) do |sql|
    people = Person.where(id: people_ids)
    people.each do |person|
      sql = sql.where('photos.id in (?)', person.image_faces.select('image_faces.base_file_id')) if person.present?
    end
    sql
  end

  add_filter(:from) do |sql|
    d = date_parse(from)
    if d
      @parsed_from = d.to_date
      sql.where('shot_at >= ?', @parsed_from)
    end
  end

  add_filter(:to) do |sql|
    d = date_parse(to)
    if d
      @parsed_to = d.to_date
      sql.where('shot_at <= ?', @parsed_to)
    end
  end

  add_filter(:labels, array: true) do |sql|
    aws_labels = ImageLabel.where('name ilike any (array[?])', labels).pluck(:id)
    if aws_labels.any?
      sql.where('photos.id in (?)',
        BaseFile.joins(:image_labels).
        where('image_labels.id in (?)', aws_labels).
        select('photos.id'))
    end
  end
end
