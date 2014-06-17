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
    return if !file.present?
    # self.fingerprint =  Phashion::Image.new(file.path).fingerprint rescue nil
    self.meta_data ||= {}
    self.meta_data.merge! get_exif.exif.reduce({}){|a,e|a.merge(e)}.except(:user_comment).stringify_keys rescue nil
    self.meta_data_will_change!
    if Photo.slow_callbacks
      set_top_colors
    end
    self.save
  end

  def set_top_colors
    self.top_colors =  begin
                         r = `convert #{file.path} -posterize 5 -define histogram:unique-colors=true -colorspace HSL -format %c histogram:info:- | sort -n -r | head`
                         r.split("\n").map{|i|
                           Hash[
                             [:h,:s,:l].zip( i[/\(([^\)]*)\)/, 1].strip.split(/[, ]+/).map(&:to_i) )
                           ]
                         }
                       end
  end

  def get_exif
    @_exif ||= file.path && EXIFR::JPEG.new(file.path)
  end

  def exif
    (self.meta_data || {}).except('fingerprint', 'top_colors')
  end

  def update_gps
    if gps = get_exif.gps
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
