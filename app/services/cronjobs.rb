module Cronjobs
  def self.rekognize(time_limit: 2.days.ago)
    if Setting['rekognition.enabled']
      Photo.where('created_at > ?', time_limit).limit(500).where(rekognition_labels_run: false, error_on_processing: false).each do |file|
        begin
          file.rekognize_labels
          file.update rekognition_labels_run: true
        rescue StandardError => e
          file.update error_on_processing: true
          Rails.logger.error "Error while rekognizing labels #{file.id} -> #{e.inspect}"
        end
      end
    end

    if Setting['rekognition.faces.enabled']
      Photo.where('created_at > ?', time_limit).limit(500).where(rekognition_labels_run: true, rekognition_faces_run: false, error_on_processing: false).each do |file|
        begin
          file.rekognize_faces
        rescue StandardError => e
          file.update error_on_processing: true
          Rails.logger.error "Error while rekognizing faces #{file.id} -> #{e.inspect}"
        end
      end
    end
  end

  def self.process_videos(limit: 5)
    Video.order('shot_at desc').where(video_processed: false, error_on_processing: false).limit(limit).each do |video|
      begin
        video.process_versions!
      rescue Aws::S3::Errors::NoSuchKey, CarrierWave::ProcessingError => e
        Rails.logger.error "ERROR Processing Video #{video.id} - #{e.inspect}"
        video.update error_on_processing: true
      rescue StandardError => e
        Rails.logger.error "UNKNOWN ERROR Processing Video #{video.id} - #{e.inspect}"
        video.update error_on_processing: true
      end
    end
  end

end
