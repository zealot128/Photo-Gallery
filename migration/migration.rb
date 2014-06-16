mapping = Hash[YAML.load_file('migration/picsmapping.yml')]
Photo.slow_callbacks = false
Photo.find_each do |photo|
  path_component = mapping[photo.id]
  path = Rails.root.join("public/photos/original#{path_component}")
  photo.file = File.open path
  photo.set_metadata
  if photo.save
    File.unlink path
  end
end
Photo.slow_callbacks = true
Day.find_each { |i| i.update_me }

