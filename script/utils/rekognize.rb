max = 300

puts "Trying to label #{max} images"
puts "------------------------------"

sql = Photo.order('created_at desc').limit(max).where(rekognition_labels_run: false, error_on_processing: false)
dates = sql.map(&:created_at)
puts "Found #{sql.count} images from #{dates.first} to #{dates.last}"
sql.each do |file|
  begin
    file.rekognize_labels
    file.update rekognition_labels_run: true
  rescue StandardError => e
    file.update_column :error_on_processing,  true
    Rails.logger.error "Error while rekognizing labels #{file.id} -> #{e.inspect}"
  end
end

puts "Trying to rekognize faces of #{max} images"
puts "------------------------------"

sql = Photo.order('created_at desc').
  limit(max).
  where(rekognition_labels_run: true, rekognition_faces_run: false, error_on_processing: false).
  joins(:image_labels).where(image_labels: { name: ['People', 'Person', 'Child'] }).group('photos.id')
dates = sql.map(&:created_at)
puts "Found #{sql.count} images from #{dates.first} to #{dates.last}"
sql.each do |file|
  begin
    file.rekognize_faces
  rescue StandardError => e
    file.update error_on_processing: true
    Rails.logger.error "Error while rekognizing faces #{file.id} -> #{e.inspect}"
  end
end
