module Cronjobs
  def self.rekognize
    Photo.where('created_at > ?', 2.days.ago).where(rekognition_labels_run: false).each do |file|
      begin
        file.rekognize_labels
      rescue StandardError => e
        Rails.logger.error "Error while rekognizing labels #{file.id} -> #{e.inspect}"
      end
    end

    Photo.where('created_at > ?', 2.days.ago).where(rekognition_labels_run: true, rekognition_faces_run: false).each do |file|
      begin
        file.rekognize_faces
        file.image_faces.each do |i|
          ImageFace.find(i).auto_assign_person
        end
      rescue StandardError => e
        Rails.logger.error "Error while rekognizing faces #{file.id} -> #{e.inspect}"
      end
    end

  end

end
