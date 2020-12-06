require "shrine"
require "shrine/storage/file_system"
require "shrine/storage/s3"
require "image_processing/vips"
Shrine.plugin :signature
Shrine.plugin :derivatives, storage: :other_store
Shrine.plugin :activerecord           # loads Active Record integration
Shrine.plugin :cached_attachment_data # enables retaining cached file across form redisplays
Shrine.plugin :restore_cached_data    # extracts metadata for assigned cached files
Shrine.plugin :refresh_metadata       # allow re-extracting metadata
Shrine.plugin :tempfile

Shrine.plugin :determine_mime_type, analyzer: :marcel

Shrine.plugin :dynamic_storage

s = ->(key) {
  setting = begin
              Setting.find_by(var: key)
            rescue ActiveRecord::StatementInvalid
              nil
            end
  if setting
    setting.value
  else
    Setting[key]
  end
}

##################
#### Storages ####
##################
Shrine.storages = {
  cache: Shrine::Storage::FileSystem.new("public", prefix: "photos/cache"),
  file: Shrine::Storage::FileSystem.new("public", prefix: "photos"),
  derivates: Shrine::Storage::FileSystem.new("public", prefix: "photos"),
}
if Rails.env.test?
  Shrine.storages[:file] = Shrine::Storage::FileSystem.new("public", prefix: "test/photos")
  Shrine.storages[:derivatives] = Shrine::Storage::FileSystem.new("public", prefix: "test/photos")
end
Shrine.storage(/aws/) do
  Shrine::Storage::S3.new(
    bucket: s.call('aws.bucket'),
    access_key_id: s.call('aws.access_key_id'),
    secret_access_key: s.call('aws.access_key_secret'),
    region: s.call('aws.region')
  )
end
Shrine.storage(/s3_external/) do
  Shrine::Storage::S3.new({
    bucket: ENV['STORAGE_BUCKET'],
    endpoint: ENV['STORAGE_ENDPOINT'],
    access_key_id: ENV['STORAGE_ACCESS_KEY_ID'],
    secret_access_key: ENV['STORAGE_ACCESS_KEY_SECRET'],
    region: ENV['STORAGE_REGION'],
    force_path_style: ENV['STORAGE_FORCE_PATH_STYLE'].present?
  }.delete_if { |k, v| v.nil? })
end

Shrine.plugin :backgrounding # upload + metadata in bg
Shrine::Attacher.promote_block do
  Shrine::PromoteJob.perform_later(self.class.name, record, name.to_s, file_data)
end
Shrine::Attacher.destroy_block do
  Shrine::DestroyJob.perform_later(self.class.name, data)
end
FFMPEG.logger.level = :warn
