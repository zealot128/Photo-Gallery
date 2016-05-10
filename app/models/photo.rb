class Photo < BaseFile
  mount_uploader :file, ImageUploader

  include PhotoMetadata

  def self.parse_date(file, current_user)
    date = nil
    begin
      meta = EXIFR::JPEG.new(file.path)
      date = meta.exif[:date_time] || meta.exif[:date_time_original] rescue nil
    rescue EXIFR::MalformedJPEG
    end
    FileDateParser.new(file: file, user: current_user, exif_date: date).parsed_date
  end

  def self.create_from_upload(file, current_user)
    photo = Photo.new
    transaction do
      date = Photo.parse_date(file, current_user)
      begin
        meta = EXIFR::JPEG.new(file.path)
        if meta.gps
          photo.lat = meta.gps.latitude
          photo.lng = meta.gps.longitude
        end
      rescue EXIFR::MalformedJPEG
      end
      photo.shot_at = date
      photo.user = current_user
      photo.file = file
      photo.update_gps
      photo.save
    end
    photo
  end

  def rotate!(direction)
    degrees =  case direction.to_sym
               when :left
                 -90
               when :flip
                 180
               else
                 90
               end
    cmd = "mogrify -rotate #{degrees} #{Shellwords.escape(file.path)}"
    `#{cmd}`
    self.fingerprint = nil
    file.recreate_versions!
    save
  end
end
