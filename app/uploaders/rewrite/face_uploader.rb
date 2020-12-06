module Rewrite
  class FaceUploader < ::Shrine
    plugin :default_storage, store: -> {
      Setting.storage_for(:faces)
    }
    def generate_location(io, derivative: nil, record: nil, metadata: nil, **options)
      extname = File.extname(metadata['filename'])
      user_name = File.basename(metadata['filename'], extname)
      filename = "#{user_name}-#{metadata['md5']}#{extname}"
      "faces/#{record.id}/#{filename}"
    end
  end
end
