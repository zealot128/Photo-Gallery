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

class Video < BaseFile
  mount_uploader :old_file, VideoUploader
  include Rewrite::VideoUploader::Attachment.new(:file)
  has_many :video_thumbnails, dependent: :destroy

  def exif
    (meta_data.dig('ffprobe', 'tags') || {}).merge(
      {
        duration: duration,
        durationHuman: duration_human
      }
    )
  end

  def duration
    meta_data.dig('ffprobe', 'duration')
  end

  def duration_human
    return "" unless duration

    Video.seconds_to_time_string(duration)
  end

  def self.seconds_to_time_string(seconds)
    sec_num = seconds.to_f
    hours   = (sec_num / 3600).floor
    minutes = ((sec_num - (hours * 3600)) / 60).floor
    seconds = sec_num - (hours * 3600) - (minutes * 60)
    sprintf "%02d:%02d:%02d", hours, minutes, seconds
  end

  def self.create_from_upload(file, user)
    r = `ffprobe #{Shellwords.escape(file.path)} -show_format -print_format json 2> /dev/null`

    if $?.success?
      meta_data = JSON.parse(r)['format']
    else
      Rails.logger.error 'Error running ffprobe, make sure ffmpeg is installed'
      meta_data = { 'tags' => {} }
    end

    meta_date = meta_data['tags']['creation_time']
    video = Video.new
    transaction do
      date = FileDateParser.new(file: file, user: user, exif_date: meta_date).parsed_date
      video.shot_at = date
      video.user = user
      video.file = file
      video.save
    end
    video
  end

  def enqueue_jobs
    if !processed?(:geocoding)
      BaseFile::GeocodeJob.perform_later(self)
    end
  end

  def update_gps(save: true)
    if meta_data && meta_data.dig('exif', 'gps_latitude')
      self.lat = meta_data['exif']['gps_latitude']
      self.lng = meta_data['exif']['gps_longitude']
      reverse_geocode
      self.save if save
      return
    end
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

  def as_json(opts = {})
    super.merge(
      thumbnails: file_derivatives[:screenshots].map(&:url),
      video_processed: file_derivatives.present?,
      exif: exif,
    )
  end
end
