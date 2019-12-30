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
#  video_processed        :boolean          default(FALSE)
#  error_on_processing    :boolean          default(FALSE)
#  duration               :integer
#  mark_as_deleted_on     :datetime
#  rekognition_ocr_run    :boolean          default(FALSE)
#

class Photo < BaseFile
  mount_uploader :file, ImageUploader

  def exif
    (self.meta_data || {}).except('fingerprint', 'top_colors')
  end

  def mime_type
    `file #{Shellwords.escape file.path} --mime-type -b`.strip
  end

  after_create_commit :enqueue_jobs

  def enqueue_jobs
    Photo::MetaDataJob.set(wait: 5.seconds).perform_later(self)
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
    photo.create_versions_later if photo.persisted?
    photo
  end

  def update_gps(save: true)
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

    retrieve_and_reprocess do |file|
      cmd = "mogrify -rotate #{degrees} #{Shellwords.escape(file.path)}"
      `#{cmd}`
    end
    self.fingerprint = Phashion::Image.new(file.path).fingerprint rescue nil
    save
  end

  def as_json(op = {})
    super.merge('faces' => image_faces.as_json)
  end

  def process_versions!
    Rails.logger.info "Starting processing of #{id}"
    file.process_now = true
    file.recreate_versions!
    save!
    Rails.logger.info "Finished processing of #{id}"
  end
end
