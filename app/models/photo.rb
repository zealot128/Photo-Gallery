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
    # move date into application's timezone (+DST Stuff), as EXIF has no timezone info...
    # TODO move to user
    assumed_timezone = Time.zone
    date.to_datetime.change(offset: date.in_time_zone(assumed_timezone).strftime("%z"))
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
