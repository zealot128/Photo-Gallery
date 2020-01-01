class ImageUploader < BaseFileUploader
  include CarrierWave::Vips

  version :preview, if: :process_now? do
    storage Setting['storage.default'].to_sym
    process :auto_orient
    process resize_to_fit: [300, 300]
    def store_dir
      store_dir_version('preview')
    end
  end

  version :thumb, if: :process_now? do
    storage Setting['storage.default'].to_sym
    process :auto_orient
    process resize_to_fill: [30, 30]
    def store_dir
      store_dir_version('thumb')
    end
  end

  version :medium, if: :process_now? do
    storage Setting['storage.default'].to_sym
    process :auto_orient
    process resize_to_fit: [500, 500]
    def store_dir
      store_dir_version('medium')
    end
  end

  version :large, if: :process_now? do
    storage Setting['storage.large'].to_sym
    process :auto_orient
    process resize_to_fit: [1200, 1000]
    def store_dir
      store_dir_version('large')
    end
  end
end
