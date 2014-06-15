module PhotoMetadata
  extend ActiveSupport::Concern

  included do
    after_create :set_metadata
    store_accessor :meta_data, :fingerprint
    store_accessor :meta_data, :top_colors

    def top_colors
      JSON.load(super) rescue []
    end

    def top_colors=(val)
      super val.to_json
    end

    reverse_geocoded_by :lat, :lng do |obj,results|
      if geo = results.first
        parts = [geo.city]
        parts << geo.address_components_of_type("establishment").first["short_name"]  rescue nil
        parts << geo.address_components_of_type("sublocality").first["short_name"] rescue nil
        obj.update_attribute(:location, parts.join(" - "))
      end
    end

  end


  def set_metadata
    self.top_colors =  begin
                         r = `convert #{file.path} -posterize 5 -define histogram:unique-colors=true -colorspace HSL -format %c histogram:info:- | sort -n -r | head`
                         r.split("\n").map{|i|
                           Hash[
                             [:h,:s,:l].zip( i[/\(([^\)]*)\)/, 1].strip.split(/[, ]+/).map(&:to_i) )
                           ]
                         }
                       end
    # self.fingerprint =  Phashion::Image.new(file.path).fingerprint rescue nil
    self.meta_data = self.meta_data.merge(exif)
    save
  end

  def exif
    meta_data = EXIFR::JPEG.new(file.path)
    meta_data.exif.inject({}) {|a,e| a.merge e}.except(:user_comment) rescue {}
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
