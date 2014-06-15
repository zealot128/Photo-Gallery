module PhotoMetadata
  extend ActiveSupport::Concern

  included do
  end

  def top_colors
    self.exif_info['top_colors'] ||= begin
                                  r = `convert #{file.path} -posterize 5 -define histogram:unique-colors=true -colorspace HSL -format %c histogram:info:- | sort -n -r | head`
                                  hash = r.split("\n").map{|i|
                                    Hash[
                                      [:h,:s,:l].zip( i[/\(([^\)]*)\)/, 1].strip.split(/[, ]+/).map(&:to_i) )
                                    ]
                                  }
                                  self.exif_info['top_colors'] = hash
                                  self.update_attribute :exif_info, exif_info
                                  hash
                                end
  end
  def fingerprint
    self.exif_info['fingerprint'] ||= begin
                                        self.exif_info['fingerprint'] = Phashion::Image.new(file.path).fingerprint

                                        self.update_attribute :exif_info, exif_info
                                        self.exif_info['fingerprint']
                                      end
  end
  def exif
    self.exif_info || begin
    self.exif_info = meta_data.exif.inject({}) {|a,e| a.merge e}.except(:user_comment) rescue {}
    self.save
    self.exif_info
    end
  end
  def meta_data
    @meta_data ||= EXIFR::JPEG.new(file.path)
  end

  def update_gps
    if gps = meta_data.gps
      self.lat = gps.latitude
      self.lng = gps.longitude
      reverse_geocode
    end
  end


  def ocr
    return if !Rails.application.config.features.ocr
    path = Shellwords.escape file.path(:original)
    t = Tempfile.new( [File.basename(path), ".tif"] )

    Rails.logger.info `convert -depth 8 -colorspace Gray -auto-orient #{path} #{t.path}`
    unless $?.success?
      raise Exception.new("Error with converting grayscale image")
    end
    Rails.logger.info `tesseract #{t.path} #{t.path} -l deu 2>&1`
    unless $?.success?
      raise Exception.new("Error with tesseract-ocr")
    end
    self.description = File.read(t.path + ".txt")
    self.save
  end

end
