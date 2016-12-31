module Cronjobs
  def self.rekognize
    if Setting['rekognition.enabled']
      Photo.where('created_at > ?', 2.days.ago).where(rekognition_labels_run: false).each do |file|
        begin
          file.rekognize_labels
        rescue StandardError => e
          Rails.logger.error "Error while rekognizing labels #{file.id} -> #{e.inspect}"
        end
      end
    end

    if Setting['rekognition.faces.enabled']
      Photo.where('created_at > ?', 2.days.ago).where(rekognition_labels_run: true, rekognition_faces_run: false).each do |file|
        begin
          file.rekognize_faces
        rescue StandardError => e
          Rails.logger.error "Error while rekognizing faces #{file.id} -> #{e.inspect}"
        end
      end
    end

  end

  def self.process_videos(limit: 5)
    Video.order('shot_at desc').where(video_processed: false).limit(limit).each do |video|
      binding.pry
      begin
        video.process_versions!
      rescue Aws::S3::Errors::NoSuchKey
      end
    end
  end

end
