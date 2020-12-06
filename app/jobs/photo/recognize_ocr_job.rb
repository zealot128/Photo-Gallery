class Photo::RecognizeOcrJob < ApplicationJob
  queue_as :default

  def perform(photo)
    text = REKOGNITION_CLIENT.ocr(photo)
    if text.strip.present? && text.length > 10
      ocr_result || photo.build_ocr_result
      ocr_result.text = text
      ocr_result.save!
    end
    photo.processed_successfully!(:ocr)
  rescue Aws::Rekognition::Errors::InvalidS3ObjectException
  end
end
