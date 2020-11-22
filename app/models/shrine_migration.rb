module ShrineMigration
  ### <BEGIN-MIGRATION> ###
  # Migrate from Carrierwave to Shrine
  def migrate!
    uploader = old_file
    attacher = Shrine::Attacher.from_model(self, :file)
    storage = Setting.storage_for(:original)
    attacher.set _shrine_file(uploader, storage)
    uploader.versions.each do |version_name, version|
      storage = Setting.storage_for(version_name.to_sym)
      attacher.merge_derivatives(version_name => _shrine_file(version, storage))
    end
    save!
  end

  def _shrine_file(uploader, storage_key)
    name     = uploader.mounted_as
    filename = read_attribute(name)

    storage = Shrine.find_storage(storage_key)
    path = uploader.
      store_path(filename).
      remove(storage.prefix.to_s).
      remove(%r{^/})

    Shrine.uploaded_file(
      storage:  storage_key,
      id:       path,
      metadata: { "filename" => filename }
    )
  end
end
