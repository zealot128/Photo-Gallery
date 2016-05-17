class Photo < BaseFile
  mount_uploader :file, ImageUploader

  include PhotoMetadata

  def self.parse_date(file, current_user)
    date = MetaDataParser.new(file.path).shot_at_date
    FileDateParser.new(file: file, user: current_user, exif_date: date).parsed_date
  end

  def self.create_from_upload(file, current_user)
    photo = Photo.new
    transaction do
      date = Photo.parse_date(file, current_user)
      photo.shot_at = date
      photo.user = current_user
      photo.file = file
      photo.save
    end
    photo
  end

  protected def update_gps(save: true)
    if meta_data && meta_data['gps_latitude']
      self.lat = meta_data['gps_latitude']
      self.lng = meta_data['gps_longitude']
      reverse_geocode
      self.save if save
    end
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
