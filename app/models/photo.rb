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
    self.share_hash = SecureRandom.base64(24)
  end

  def exif
    meta_data.exif.inject({}) {|a,e| a.merge e}
  end

  def meta_data
    @meta_data ||= EXIFR::JPEG.new(file.path)
  end


  scope :dates, group(:shot_at).select(:shot_at).order("shot_at desc")
end
