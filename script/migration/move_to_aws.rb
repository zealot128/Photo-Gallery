count = Photo.count
i = 0
Photo.find_each do |photo|
  puts "#{i+=1} / #{count}"
  if !photo.file.file.exists?
    local_photo_path = Rails.root.join('public/', photo.file.path)
    if !File.exists?(local_photo_path)
      puts "ERROR: cant upload #{photo.id} #{local_photo_path} not exists!"
      next
    end
    photo.file = File.open(local_photo_path)
    if photo.md5.blank?
      photo.set_metadata
    else
      photo.save!
    end
  end
end
