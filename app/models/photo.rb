class Photo < ActiveRecord::Base
  has_attached_file :file, styles: {
    preview:  "300x300",
    medium: "500x500>",
    large:  "1000x1000>"
  },
  path:   ":rails_root/public/photos/:style/:date/:basename.:extension",
  url:    "/photos/:style/:date/:basename.:extension",
  convert_options: { all: '-auto-orient' }

  belongs_to :user

  before_save do
    self.share_hash = SecureRandom.hex(24)
  end

  def exif
    meta_data.exif.inject({}) {|a,e| a.merge e}
  end

  def meta_data
    @meta_data ||= EXIFR::JPEG.new(file.path)
  end

  def self.create_from_upload(file, current_user)

    photo = Photo.new
    meta = EXIFR::JPEG.new(file.path)
    date = meta.exif[:date_time] || meta.exif[:date_time_original]
    if date.is_a? String
      case date
      # correction for exif from hd cam
      when /^(\d{4}):(\d{1,2}):(\d{1,2})/
        date = Date.parse("#$1-#$2-#$3")
      else
        date = Date.parse(date)
      end
    end

    if meta.gps
      photo.lat = meta.gps.latitude
      photo.lng = meta.gps.longitude
    end

    photo.shot_at = date.to_date
    photo.user = current_user
    photo.file = file
    photo.save
  end

  def self.grouped
    days = Photo.all.group_by{|i|i.shot_at.to_date}.sort_by{|a,b| a}.reverse
    #  [datum, [items]] ...
    #  [month, [ [datum, items], ...

    days.group_by{|day, items| Date.parse day.strftime("%Y-%m-01")}
  end

  scope :dates, group(:shot_at).select(:shot_at).order("shot_at desc")
end
