class ImageUploader < CarrierWave::Uploader::Base
  # Include RMagick or MiniMagick support:
  # include CarrierWave::RMagick
  include CarrierWave::MiniMagick

  storage Setting['storage.original'].to_sym

  def auto_orient
    `mogrify -auto-orient #{Shellwords.escape current_path}`
  end

  def store_dir
    store_dir_version('original')
  end

  # using the day of the associated date - this way we ignore Timezone, that might conflict with the ShotAt date and keep the paths
  def store_dir_version(version)
    date = model.shot_at_without_timezone
    "photos/#{version}/#{date.year}/#{date.to_s}"
  end

  # Create different versions of your uploaded files:
  version :preview do
    storage Setting['storage.default'].to_sym
    process :auto_orient
    process :resize_to_fit => [300,300]
    def store_dir
      store_dir_version('preview')
    end
  end
  version :thumb do
    storage Setting['storage.default'].to_sym
    process :auto_orient
    process :resize_to_fill => [30,30]
    def store_dir
      store_dir_version('thumb')
    end
  end
  version :medium do
    storage Setting['storage.default'].to_sym
    process :auto_orient
    process :resize_to_fit => [500,500]
    def store_dir
      store_dir_version('medium')
    end
  end
  version :large do
    storage Setting['storage.large'].to_sym
    process :auto_orient
    process :resize_to_fit => [1200,1000]
    def store_dir
      store_dir_version('large')
    end
  end

end
