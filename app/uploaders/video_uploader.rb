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
    "photos/#{version}/#{model.shot_at.year}/#{model.shot_at.to_date.to_s}"
  end

  version :preview do
    process encode_video: [:jpg, resolution: '500x500', preserve_aspect_ratio: :width ]
    storage :file
    def store_dir
      store_dir_version('preview')
    end
  end

  version :medium do
    process encode_video: [:mp4, resolution: '640x360', preserve_aspect_ratio: :width ]
    def store_dir
      store_dir_version('medium')
    end
  end

end
