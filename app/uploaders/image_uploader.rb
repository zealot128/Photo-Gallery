class ImageUploader < CarrierWave::Uploader::Base

  # Include RMagick or MiniMagick support:
  # include CarrierWave::RMagick
  include CarrierWave::MiniMagick

  if Rails.application.secrets.storage == 'file'
    storage :file
  else
    storage :fog
  end

  def auto_orient
    `mogrify -auto-orient #{Shellwords.escape current_path}`
  end

  # Override the directory where uploaded files will be stored.
  # This is a sensible default for uploaders that are meant to be mounted:
  def store_dir
    store_dir_version('original')
  end

  def store_dir_version(version)
    "photos/#{version}/#{model.shot_at.year}/#{model.shot_at.to_date.to_s}"
  end

  # def default_url
  #   # ActionController::Base.helpers.asset_path("fallback/" + [version_name, "default.png"].compact.join('_'))
  #   "/images/fallback/" + [version_name, "default.png"].compact.join('_')
  # end


  # Create different versions of your uploaded files:
  version :preview do
    storage :file
    process :auto_orient
    process :resize_to_fit => [300,300]
    def store_dir
      store_dir_version('preview')
    end
  end
  version :thumb do
    storage :file
    process :auto_orient
    process :resize_to_fill => [30,30]
    def store_dir
      store_dir_version('thumb')
    end
  end
  version :medium do
    storage :file
    process :auto_orient
    process :resize_to_fit => [500,500]
    def store_dir
      store_dir_version('medium')
    end
  end
  version :large do
    storage :file
    process :auto_orient
    process :resize_to_fit => [1200,1000]
    def store_dir
      store_dir_version('large')
    end
  end

end
