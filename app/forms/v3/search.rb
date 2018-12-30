# rubocop:disable Style/ClassVars
class V3::Search
  DATE_COLUMN = "(shot_at at time zone 'Europe/Berlin')::date"
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
  attr_accessor :query
  attr_reader :file_size_min, :file_size_max
  attr_reader :parsed_from, :parsed_to
  attr_accessor :include_whole_day

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

  def overview
    filtered_sql.group_by_month(:shot_at).count
  end

  def media
    filtered_sql.
      order('shot_at desc').
      paginate(page: page, per_page: 50)
  end

  def filtered_sql
    sql = BaseFile.visible.
      includes(:image_faces, :image_labels, :liked_by, :people, :shares, :tags, :day)
    self.class.filters.each do |column, filter|
      next if send(column).blank?
      new_sql = instance_exec(sql, &filter)
      sql = new_sql if new_sql
    end
    sql
  end

  add_filter(:favorite) do |sql|
    if favorite == 'true'
      sql.where('(select 1 from likes where base_file_id = photos.id) is not null')
    end
  end

  add_filter(:query) do |sql|
    words = query.split(" ").map{|i| "%#{i}%" }
    ocr = OcrResult.where('text ilike any (array[?])', words).select('base_file_id')
    tags = ActsAsTaggableOn::Tag.
      where('name ilike any (array[?])', words).
      joins(:taggings).
      where('taggable_type = ?', 'BaseFile').select("taggable_id")
    labels = ImageLabel.where('name ilike any (array[?]) or name_de ilike any (array[?])', words, words).
      joins("INNER JOIN \"base_files_image_labels\" ON \"base_files_image_labels\".\"image_label_id\" = \"image_labels\".\"id\"").
      select('base_file_id')

    sql.where("photos.id in (?) or photos.id in (?) or photos.id in (?)", ocr, tags, labels)
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
    people_sql = sql
    people.each do |person|
      people_sql = people_sql.where('photos.id in (?)', person.image_faces.select('image_faces.base_file_id')) if person.present?
    end
    if include_whole_day == 'true'
      dates = people_sql.select(DATE_COLUMN)
      sql = sql.where("#{DATE_COLUMN} in (?)", dates)
    else
      sql = people_sql
    end
    sql
  end

  add_filter(:from) do |sql|
    d = date_parse(from)
    if d
      @parsed_from = d.to_date
      sql.where("#{DATE_COLUMN} >= ?", @parsed_from)
    end
  end

  add_filter(:to) do |sql|
    d = date_parse(to)
    if d
      @parsed_to = d.to_date
      sql.where("#{DATE_COLUMN} <= ?", @parsed_to)
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

  add_filter(:camera_models, array: true) do |sql|
    sql.where("(regexp_replace(meta_data::text, '\\\\u0000', '', 'g'))::json->>'model' in (?)", camera_models)
  end
end
