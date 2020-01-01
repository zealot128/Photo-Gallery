class Photo::OcrJob < ApplicationJob

  queue_as :default

  def perform(photo)
    photo.file.download do |file|
      path = Shellwords.escape file.path
      t = Tempfile.new([File.basename(path), ".tif"])

      Rails.logger.info `convert -depth 8 -colorspace Gray -auto-orient #{path} #{t.path}`
      unless $CHILD_STATUS.success?
        raise StandardError, "Error with converting grayscale image"
      end

      language = Setting['tesseract_language']

      Rails.logger.info `tesseract #{t.path} #{t.path} -l #{language} 2>&1`
      unless $CHILD_STATUS.success?
        raise StandardError, "Error with tesseract-ocr"
      end
      text = File.read(t.path + ".txt").strip
      if text.present?
        ocr_result = photo.ocr_result || photo.build_ocr_result
        ocr_result.update(text: text)
      end
      photo.processed_successfully!(:ocr)
    end
  end
end
