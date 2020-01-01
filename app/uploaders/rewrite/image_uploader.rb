module Rewrite
  class ImageUploader < Rewrite::BaseFileUploader
    add_metadata :exif do |io, derivate: nil, **options|
      next unless options[:background]

      MetaDataParser.new(io).exif
    end

    Attacher.derivatives do |original|
      base = Setting.vips_installed? ? ImageProcessing::Vips : ImageProcessing::MiniMagick

      magick = base.source(original)
        .convert("jpg")
      {
        preview: magick.resize_to_fit!(300, 300),
        thumb: magick.resize_to_fit!(30, 30),
        medium: magick.resize_to_fit!(500, 500),
        large: magick.resize_to_fit!(1200, 1000),
      }
    end
  end
end
