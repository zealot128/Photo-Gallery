class Photo < BaseFile
  mount_uploader :file, ImageUploader

  include PhotoMetadata

	after_create :rekognize_labels

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

  def rekognize_labels
    if Rails.application.secrets[:rekognition_collection]
      aws_labels = RekognitionClient.labels(self)
      aws_labels.labels.each do |aws_label|
        image_labels.where(name: aws_label.name).first ||
          begin
            label = ImageLabel.where(name: aws_label.name).first_or_create
            image_labels << label
          end
      end
    end
  rescue Aws::Rekognition::Errors::InvalidS3ObjectException
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

    retrieve_and_reprocess do |file|
      cmd = "mogrify -rotate #{degrees} #{Shellwords.escape(file.path)}"
      `#{cmd}`
    end
    self.fingerprint = nil
    save
  end
end
