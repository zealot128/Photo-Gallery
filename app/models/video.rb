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
#

class Video < BaseFile
  mount_uploader :file, VideoUploader
  has_many :video_thumbnails, dependent: :destroy

  def duration_from_metadata
    (meta_data || {}).fetch("ffprobe", {}).fetch("duration", 0).to_f.round
  end

  def exif
    {
      duration: duration,
      durationHuman: duration_human
    }
  end

  def duration_human
    return "" if !duration
    Video.seconds_to_time_string(duration)
  end

  def self.seconds_to_time_string(seconds)
    sec_num = seconds.to_f
    hours   = (sec_num / 3600).floor
    minutes = ((sec_num - (hours * 3600)) / 60).floor
    seconds = sec_num - (hours * 3600) - (minutes * 60)
    sprintf "%02d:%02d:%02d", hours, minutes, seconds
  end

  before_save do
    self.duration = duration_from_metadata
  end

  def self.create_from_upload(file, user)
    r = `ffprobe #{Shellwords.escape(file.path)} -show_format -print_format json 2> /dev/null`
    if $?.success?
      meta_data = JSON.load(r)['format']
    else
      Rails.logger.error 'Error running ffprobe, make sure ffmpeg is installed'
      meta_data = { 'tags' => {} }
    end

    meta_date = meta_data['tags']['creation_time']
    date = FileDateParser.new(file: file, user: user, exif_date: meta_date).parsed_date
    video = Video.new
    video.shot_at = date
    video.user = user
    video.file = file
    video.meta_data = { ffprobe: meta_data }
    video.update_gps save: false
    video.save
    video
  end

  def process_versions!
    Rails.logger.info "Starting processing of #{id}"
    file.process_now = true
    file.recreate_versions!
    save!
    create_preview_thumbnails
    update video_processed: true
    save!
    Rails.logger.info "Finished processing of #{id}"
  end

  def create_preview_thumbnails
    return if !duration
    number_of_thumbnails = [ duration.to_i**(Rational(2,5)), 5].max.round

    thumbnail_every_second = duration.to_f / (number_of_thumbnails)
    points = []
    number_of_thumbnails.times do |i|
      points << (thumbnail_every_second * i).round
    end
    video_thumbnails.destroy_all

    points.each do |point|
      video_thumbnails.create(at_time: point)
    end
  end

  def update_gps(save: true)
    tags = meta_data.fetch('ffprobe', {}).fetch('tags', {})
    gps = tags['location'] || tags['location-eng']
    case gps
    when nil then return
    when /([\+\-][\d\.]+){2}/ then
      self.lat, self.lng = gps.scan(/([\+\-][\d\.]+)/).map(&:first).map(&:to_f)
      reverse_geocode
      self.save if save
    end
  end

  def as_json(opts={})
    super.merge({
      thumbnails: video_thumbnails.map{|i| i.file.url },
      video_processed: video_processed,
    })
  end
end
