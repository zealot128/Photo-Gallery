module Rewrite
  class ImageUploader < Rewrite::BaseFileUploader
    add_metadata :exif do |io, derivate: nil, **options|
      next unless options[:background]

      MetaDataParser.new(io).exif
    end

    add_metadata :id_hash do |io, derivate: nil, **options|
      Shrine.with_file(io) { |file|
        DHashVips::IDHash.fingerprint(file.path)
      }
    end

    Attacher.derivatives do |original|
      base = Setting.image_processing

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
