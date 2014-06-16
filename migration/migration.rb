mapping = Hash[YAML.load_file('migration/picsmapping.yml')]
Photo.slow_callbacks = false
Photo.find_each do |photo|
  path_component = mapping[photo.id]
  photo.file = File.open Rails.root.join("public/photos/original#{path_component}")
  photo.set_metadata
  photo.save
end
Photo.slow_callbacks = true
Day.find_each { |i| i.update_me }
