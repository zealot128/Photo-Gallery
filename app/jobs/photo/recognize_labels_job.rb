class Photo::RecognizeLabelsJob < ApplicationJob
  ALLOWED_OCR_TAGS = ["Text", "Page", "Label", "Brochure", "Flyer", "Paper", "Poster", "File", "Webpage", "Screen", "Letter", "Paper"].freeze
  ALLOWED_FACES_TAGS = %w[People Person Child].freeze

  queue_as :default

  def perform(photo)
    REKOGNITION_CLIENT.label(photo)
    photo.processed_successfully! :labels
    labels = photo.image_labels.pluck(:name)
    if Setting['rekognition.faces.enabled'] and (ALLOWED_FACES_TAGS & labels).any?
      Photo::RecognizeFacesJob.perform_later(photo)
    end
    if Setting['rekognition.enabled'] && (ALLOWED_OCR_TAGS & labels).any?
      Photo::RecognizeOcrJob.perform_later(photo)
    end
  rescue Aws::Rekognition::Errors::InvalidS3ObjectException
  end
end
