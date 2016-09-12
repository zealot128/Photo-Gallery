class VideoUploader < CarrierWave::Uploader::Base
  include CarrierWave::Video

  if Rails.application.secrets.storage == 'file'
    storage :file
  else
    storage :aws
  end

  def store_dir
    store_dir_version('original')
  end

  def store_dir_version(version)
    date = model.shot_at_without_timezone
    "photos/#{version}/#{date.year}/#{date.to_s}"
  end

  version :preview do
    process encode_video: [:jpg, resolution: '500x500', preserve_aspect_ratio: :width ]
    storage :file

    def full_filename(for_file = model.avatar.file)
      old = super
      File.basename(old, '.*') + ".jpg"
    end
  end
  version :thumb do
    process encode_video: [:jpg, resolution: '30x30', preserve_aspect_ratio: :width ]
    storage :file
    def store_dir
      store_dir_version('thumb')
    end
    def full_filename(for_file = model.avatar.file)
      old = super
      File.basename(old, '.*') + ".jpg"
    end
  end

  version :medium do
    process encode_video: [:mp4, resolution: '640x360', preserve_aspect_ratio: :width, audio_codec: Rails.application.config.features.audio_codec ]
    storage :file
    def store_dir
      store_dir_version('medium')
    end
  end

end
