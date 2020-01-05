module ShrineMigration
  ### <BEGIN-MIGRATION> ###
  # Migrate from Carrierwave to Shrine
  def migrate!
    uploader = old_file
    attacher = Shrine::Attacher.from_model(self, :file)
    storage = {
      preview: Setting['storage.default'].to_sym,
      thumb: Setting['storage.default'].to_sym,
      medium: Setting['storage.default'].to_sym,
      large: Setting['storage.large'].to_sym,
      original: Setting['storage.original'].to_sym
    }
    attacher.set _shrine_file(uploader, storage[:original])
    uploader.versions.each do |version_name, version|
      attacher.merge_derivatives(version_name => _shrine_file(version, storage[version_name.to_sym]))
    end
    save!
  end

  def _shrine_file(uploader, storage)
    name     = uploader.mounted_as
    filename = read_attribute(name)
    path     = uploader.
      store_path(filename).
      remove(Shrine.storages[storage].prefix.to_s).
      remove(%r{^/})

    Shrine.uploaded_file(
      storage:  storage,
      id:       path,
      metadata: { "filename" => filename }
    )
  end
end
