module Rewrite
  class BaseFileUploader < ::Shrine
    plugin :add_metadata
    plugin :default_storage, store: -> { Setting.storage_for(:original) }
    plugin :derivatives, storage: ->(derivative) {
      if derivative.is_a?(Array)
        Setting.storage_for(derivative.first)
      else
        Setting.storage_for(derivative)
      end
    }

    add_metadata :md5 do |io, derivative: nil, **|
      calculate_signature(io, :md5) unless derivative
    end

    def generate_location(io, derivative: nil, record: nil, metadata: nil, **options)
      date = record.shot_at_without_timezone
      version = derivative || 'original'
      if version.is_a?(Array)
        version = derivative.first
      end
      extname = File.extname(metadata['filename'])
      user_name = File.basename(metadata['filename'], extname)
      filename = "#{user_name}-#{metadata['md5']}#{extname}"
      if Rails.env.test?
        "#{version}/#{date.year}/#{date}/#{filename}"
      else
        "#{version}/#{date.year}/#{date}/#{filename}"
      end
    end
  end
end
