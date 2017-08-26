class VideoPreviewUploader < CarrierWave::Uploader::Base
  include CarrierWave::Video
  storage Setting['storage.default'].to_sym

  def store_dir
    store_dir_version('original')
  end

  def store_dir_version(version)
    date = model.video.shot_at_without_timezone
    "photos/preview/#{date.year}/#{date}"
  end

  process :create_screenshot_on_time

  def create_screenshot_on_time
    time = Video.seconds_to_time_string(model.at_time)
    # encode_video(:jpg, custom: "-vf scale=w=500:h=500:force_original_aspect_ratio=decrease -ss #{time} -frames:v 1")
    # encode_video(:jpg, resolution: '500x500', preserve_aspect_ratio: :width, custom: "-ss #{time} -frames:v 1")
    encode_video(:jpg, custom: "-vf scale=w=500:h=500:force_original_aspect_ratio=decrease -ss #{time} -frames:v 1")
  end

  def full_filename(for_file = model.avatar.file)
    old = super
    File.basename(old, '.*') + ".jpg"
  end
end
