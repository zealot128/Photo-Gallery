class Photo < ActiveRecord::Base
  has_attached_file :file, styles: {
    preview:  "300x300",
    thumb:  "30x30",
    medium: "500x500>",
    large:  "1000x1000>"
  },
  path:   ":rails_root/public/photos/:style/:date/:basename.:extension",
  url:    "/photos/:style/:date/:basename.:extension",
  convert_options: { all: '-auto-orient' }

  belongs_to :user
  belongs_to :day
  has_and_belongs_to_many :shares, :join_table => "photos_shares"

  before_save do
    self.share_hash = SecureRandom.hex(24)
    self.year = self.shot_at.year
    self.month = self.shot_at.month
  end
  before_save do
    self.day = Day.date self.shot_at
  end

  SLOW_CALLBACKS = true # override in migration script
  after_save do
    if SLOW_CALLBACKS
      self.day.update_me
    end
  end

  before_validation on: :create do
    self.md5 = Digest::MD5.hexdigest(file.to_file.read)
  end
  validates :md5, :uniqueness => true
  before_post_process :check_uniqueness
  def check_uniqueness
    valid?
  end

  def self.parse_date(file)
    meta = EXIFR::JPEG.new(file.path)
    date = meta.exif[:date_time] || meta.exif[:date_time_original] rescue nil
    if not date
      if file.original_filename[/(\d{4})[\-_\.](\d{2})[\-_\.](\d{2})/]
        date = Date.parse "#$1-#$2-#$3"
      else
        Rails.logger.warn "No Date found for file #{file.original_filename}. taking mtime"
        date = file.mtime rescue Date.today
      end
    end
    if date.is_a? String
      case date
      # correction for exif from hd cam
      when /^(\d{4}):(\d{1,2}):(\d{1,2})/
        date = Date.parse("#$1-#$2-#$3")
      else
        date = Date.parse(date)
      end
    end
    date
  end


  def self.create_from_upload(file, current_user)

    photo = Photo.new

    date = Photo.parse_date(file)

    meta = EXIFR::JPEG.new(file.path)
    if meta.gps
      photo.lat = meta.gps.latitude
      photo.lng = meta.gps.longitude
    end

    photo.shot_at = date.to_date
    photo.user = current_user
    photo.file = file
    photo.save
    photo.reverse_geocode
    photo
  end

  reverse_geocoded_by :lat, :lng do |obj,results|
    if geo = results.first
      parts = [geo.city]
      parts << geo.address_components_of_type("establishment").first["short_name"]  rescue nil
      parts << geo.address_components_of_type("sublocality").first["short_name"] rescue nil
      obj.update_attribute(:location, parts.join(" - "))
    end
  end

  def exif
    meta_data.exif.inject({}) {|a,e| a.merge e}
  end

  def modal_group
    shot_at.strftime("d%Y%m%d")
  end

  def meta_data
    @meta_data ||= EXIFR::JPEG.new(file.path)
  end


  def update_gps
    if gps = meta_data.gps
      self.lat = gps.latitude
      self.lng = gps.longitude
      reverse_geocode
    end
  end

  def self.grouped_by_day_and_month

    days = all.group_by{|i|i.shot_at.to_date}.sort_by{|a,b| a}.reverse
    #  [datum, [items]] ...
    #  [month, [ [datum, items], ...

    days.group_by{|day, items| Date.parse day.strftime("%Y-%m-01")}
  end

  def self.grouped
    days = Photo.all.group_by{|i|i.shot_at.to_date}.sort_by{|a,b| a}.reverse
    #  [datum, [items]] ...
    #  [month, [ [datum, items], ...

    days.group_by{|day, items| Date.parse day.strftime("%Y-%m-01")}
  end

  # @deprecated
  def self.days_of_year(year)
    days = Photo.where(:year => year).
      group_by{|i|i.shot_at.to_date}.
      sort_by{|a,b| a}.reverse
    days.group_by{|day, items| day.month}
  end

  def self.years
    Photo.uniq.order("year desc").pluck(:year)
  end

  scope :dates, group(:shot_at).select(:shot_at).order("shot_at desc")
  private
end
