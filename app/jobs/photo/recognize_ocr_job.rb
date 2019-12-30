class Photo::RecognizeOcrJob < ApplicationJob
  queue_as :default

  def perform(photo)
    aws = RekognitionClient.ocr(photo)
    text = aws.text_detections.map{ |i| i.detected_text }.join(' ')
    if text.strip.present? && text.length > 10
      ocr_result || photo.build_ocr_result
      ocr_result.text = text
      ocr_result.save!
    end
    update_column :rekognition_ocr_run, true
  rescue Aws::Rekognition::Errors::InvalidS3ObjectException
  end
end
