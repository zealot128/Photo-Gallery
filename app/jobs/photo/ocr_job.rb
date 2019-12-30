class Photo::OcrJob < ApplicationJob
  queue_as :default

  def perform(photo)
    return unless Setting['elasticsearch.enabled']
    path = Shellwords.escape photo.file.path(:original)
    t = Tempfile.new([File.basename(path), ".tif"])

    Rails.logger.info `convert -depth 8 -colorspace Gray -auto-orient #{path} #{t.path}`
    unless $?.success?
      raise StandardError, "Error with converting grayscale image"
    end
    Rails.logger.info `tesseract #{t.path} #{t.path} -l deu 2>&1`
    unless $?.success?
      raise StandardError, "Error with tesseract-ocr"
    end
    photo.update(description: File.read(t.path + ".txt"))
  end
end
