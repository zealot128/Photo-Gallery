# == Schema Information
#
# Table name: photos
#
#  id                     :integer          not null, primary key
#  shot_at                :datetime
#  lat                    :float
#  lng                    :float
#  user_id                :integer
#  created_at             :datetime         not null
#  updated_at             :datetime         not null
#  location               :string
#  md5                    :string
#  year                   :integer
#  month                  :integer
#  day_id                 :integer
#  caption                :string
#  description            :text
#  file                   :string
#  meta_data              :json
#  type                   :string
#  file_size              :integer
#  rekognition_labels_run :boolean          default(FALSE)
#  rekognition_faces_run  :boolean          default(FALSE)
#  aperture               :decimal(5, 2)
#

class Photo < BaseFile
  mount_uploader :file, ImageUploader

  include PhotoMetadata

	# after_create :rekognize_labels, :rekognize_faces

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
    aws_labels = RekognitionClient.labels(self)
    aws_labels.labels.each do |aws_label|
      image_labels.where(name: aws_label.name).first ||
        begin
          label = ImageLabel.where(name: aws_label.name).first_or_create
          image_labels << label
        end
      update_column :rekognition_labels_run, true
    end
  rescue Aws::Rekognition::Errors::InvalidS3ObjectException
  end

  def rekognize_faces
    if Setting['rekognition.faces.rekognition_collection']
      labels = image_labels.pluck(:name)
      if labels.include?("People") || labels.include?("Person") || labels.include?("Child")
        faces = RekognitionClient.index_faces(self)
        faces.face_records.each do |face|
          image_faces.where(aws_id: face.face.face_id).first_or_create(bounding_box: face.face.bounding_box.as_json, confidence: face.face.confidence)
        end
        update_column :rekognition_faces_run, true
      end
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

    retrieve_and_reprocess do |file|
      cmd = "mogrify -rotate #{degrees} #{Shellwords.escape(file.path)}"
      `#{cmd}`
    end
    self.fingerprint = nil
    save
  end

  def as_json(op={})
    super.merge({
      'faces' => image_faces.as_json
    })
  end
end
