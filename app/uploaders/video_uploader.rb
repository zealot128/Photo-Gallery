class VideoUploader < CarrierWave::Uploader::Base
  include CarrierWave::Video

  def process_now?(img = nil)
    (!!@process_now) || model.video_processed?
  end

  attr_writer :process_now

  storage Setting['storage.original'].to_sym

  def store_dir
    store_dir_version('original')
  end

  def store_dir_version(version)
    date = model.shot_at_without_timezone
    "photos/#{version}/#{date.year}/#{date}"
  end

  version :preview, if: :process_now? do
    process encode_video: [:jpg, custom: '-vf scale=w=500:h=500:force_original_aspect_ratio=decrease']
    storage Setting['storage.default'].to_sym

    def store_dir
      store_dir_version('preview')
    end

    def full_filename(for_file = model.avatar.file)
      old = super
      File.basename(old, '.*') + ".jpg"
    end
  end

  version :thumb, if: :process_now? do
    process encode_video: [:jpg, custom: '-vf scale=w=30:h=30:force_original_aspect_ratio=decrease']
    storage Setting['storage.default'].to_sym
    def store_dir
      store_dir_version('thumb')
    end

    def full_filename(for_file = model.avatar.file)
      old = super
      File.basename(old, '.*') + ".jpg"
    end
  end

  version :large, if: :process_now? do
    storage Setting['storage.large'].to_sym
    # process encode_video: [:mp4, resolution: '640x360', preserve_aspect_ratio: :width, audio_codec: Setting['audio_codec']]
    process encode_video: [:mp4, custom: '-strict -2 -vf "scale=-1:360, scale=trunc(iw/2)*2:360"', audio_codec: Setting['audio_codec']]

    def store_dir
      store_dir_version('large')
    end
  end
end
