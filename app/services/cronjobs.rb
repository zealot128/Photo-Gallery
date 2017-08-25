module Cronjobs
  KEEP_LOG = 30.days

  def self.run
    lock_file = Rails.root.join('tmp', 'cron.lock')
    Filelock lock_file, wait: 1.minute, timeout: 15.minutes do
      Rails.logger.info "Cronjobs.run started"
      S3Import.run
      process_videos(limit: 2)
      rekognize_labels
      rekognize_faces
      Rails.logger.info "Cronjobs.run finished"
      LoggingEntry.where('created_at < ?', KEEP_LOG).delete_all
    end
  end

  def self.rekognize_labels(time_limit: 2.days.ago)
    return unless Setting['rekognition.enabled']
    Photo.where('created_at > ?', time_limit).limit(500).where(rekognition_labels_run: false, error_on_processing: false).each do |file|
      Rails.logger.info "Cronjobs.rekognize_labels -> #{file.id}"
      begin
        file.rekognize_labels
        file.update rekognition_labels_run: true
      rescue StandardError => e
        file.update error_on_processing: true
        Rails.logger.error "Error while rekognizing labels #{file.id} -> #{e.inspect}"
      end
    end
  end

  def self.rekognize_faces(time_limit: 2.days.ago)
    return unless Setting['rekognition.faces.enabled']
    unprocessed = Photo.where('created_at > ?', time_limit).limit(500).
      where(rekognition_labels_run: true, rekognition_faces_run: false, error_on_processing: false)
    unprocessed.each do |file|
      begin
        Rails.logger.info "Cronjobs.rekognize_faces -> #{file.id}"
        file.rekognize_faces
      rescue StandardError => e
        file.update error_on_processing: true
        Rails.logger.error "Error while rekognizing faces #{file.id} -> #{e.inspect}"
      end
    end
  end

  def self.process_videos(limit: 5, videos: Video.order('shot_at desc').where(video_processed: false, error_on_processing: false).limit(limit))
    videos.each do |video|
      Rails.logger.info "Cronjobs.process_videos -> #{video.id}"
      begin
        video.process_versions!
      rescue Aws::S3::Errors::NoSuchKey, CarrierWave::ProcessingError => e
        Rails.logger.error "ERROR Processing Video #{video.id} - #{e.inspect}"
        video.update error_on_processing: true
      rescue ActiveRecord::RecordInvalid
        # duplicate md5
        if Video.where(file: video.read_attribute('file')).where(video_processed: true).where.not(id: video.id).any?
          Rails.logger.warn "Cronjobs.process_videos -> #{video.id} -> Already exists, deleting new video"
          video.destroy
        else
          Rails.logger.error "Cronjobs.process_videos -> #{video.id} -> Unkown error: #{video.errors.full_messages}"
          video.update_column error_on_processing: true
        end
      rescue StandardError => e
        Rails.logger.error "UNKNOWN ERROR Processing Video #{video.id} - #{e.inspect}"
        video.update error_on_processing: true
      end
    end
  end
end
