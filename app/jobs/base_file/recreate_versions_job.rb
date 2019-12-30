class BaseFile::RecreateVersionsJob < ApplicationJob
  queue_as :default

  def perform(video)
    video.process_versions!
  rescue Aws::S3::Errors::NoSuchKey, CarrierWave::ProcessingError => e
    Rails.logger.error "ERROR Processing Video #{video.id} - #{e.inspect}"
    video.update error_on_processing: true
  rescue ActiveRecord::RecordInvalid
    # Do something later
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
