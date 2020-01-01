# == Schema Information
#
# Table name: photos
#
#  id                 :integer          not null, primary key
#  shot_at            :datetime
#  lat                :float
#  lng                :float
#  user_id            :integer
#  created_at         :datetime
#  updated_at         :datetime
#  location           :string
#  md5                :string
#  year               :integer
#  month              :integer
#  day_id             :integer
#  caption            :string
#  description        :text
#  old_file           :string
#  type               :string
#  mark_as_deleted_on :datetime
#  geohash            :integer
#  fingerprint        :string
#  file_data          :jsonb
#  processing_flags   :jsonb
#

class Photo < BaseFile
  mount_uploader :old_file, ImageUploader
  include Rewrite::ImageUploader::Attachment.new(:file)

  def exif
    meta_data&.[]('exif')
  end

  def aperture
    exif&.[]('aperture')
  end

  def enqueue_jobs
    if !processed?(:labels) and Setting['rekognition.enabled']
      Photo::RecognizeLabelsJob.perform_later(self)
    end
    if !processed?(:ocr) and Setting.tesseract_installed?
      Photo::OcrJob.perform_later(self)
    end
    if !processed?(:geocoding)
      BaseFile::GeocodeJob.perform_later(self)
    end
  end

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

  def update_gps(save: true)
    if meta_data && meta_data.dig('exif', 'gps_latitude')
      self.lat = meta_data['exif']['gps_latitude']
      self.lng = meta_data['exif']['gps_longitude']
      reverse_geocode
      self.save if save
    end
  end

  def rotate!(direction)
    raise

    degrees = case direction.to_sym
              when :left
                -90
              when :flip
                180
              else
                90
              end

    cmd = "mogrify -rotate #{degrees} #{Shellwords.escape(file.path)}"
    `#{cmd}`
    save
  end

  def as_json(options = {})
    super.merge('faces' => image_faces.as_json)
  end
end
