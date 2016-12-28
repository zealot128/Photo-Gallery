class VideoUploader < CarrierWave::Uploader::Base
  include CarrierWave::Video

  storage Setting['storage.original']

  def store_dir
    store_dir_version('original')
  end

  def store_dir_version(version)
    date = model.shot_at_without_timezone
    "photos/#{version}/#{date.year}/#{date.to_s}"
  end

  version :preview do
    process encode_video: [:jpg, resolution: '500x500', preserve_aspect_ratio: :width ]
    storage Setting['storage.default']

    def store_dir
      store_dir_version('preview')
    end
    def full_filename(for_file = model.avatar.file)
      old = super
      File.basename(old, '.*') + ".jpg"
    end
  end
  version :thumb do
    process encode_video: [:jpg, resolution: '30x30', preserve_aspect_ratio: :width ]
    storage Setting['storage.default']
    def store_dir
      store_dir_version('thumb')
    end
    def full_filename(for_file = model.avatar.file)
      old = super
      File.basename(old, '.*') + ".jpg"
    end
  end

  version :large do
    storage Setting['storage.large']
    process encode_video: [:mp4, resolution: '640x360', preserve_aspect_ratio: :width, audio_codec: Setting['audio_codec'] ]
    def store_dir
      store_dir_version('large')
    end
  end

end
