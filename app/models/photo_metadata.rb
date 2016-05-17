module PhotoMetadata
  class NullMetaData
    def exif
      {}
    end
    def gps
    end
  end
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


  end

  def mime_type
    `file #{Shellwords.escape file.path} --mime-type -b`.strip
  end

  def get_fingerprint!
    if !self.file.cached?
      file.cache!
    end
    self.fingerprint = Phashion::Image.new(file.path).fingerprint rescue nil
  end

  def set_metadata
    return if !file.present?
    self.meta_data ||= {}
    self.meta_data.merge! get_exif.exif.reduce({}){|a,e|a.merge(e)}.except(:user_comment).stringify_keys rescue nil
    if self.meta_data['orientation'].is_a? EXIFR::TIFF::Orientation
      self.meta_data['orientation'] = self.meta_data['orientation'].instance_variable_get("@type")
    end
    self.meta_data_will_change!
    if Photo.slow_callbacks
      set_top_colors
    end
    self.md5 = Digest::MD5.hexdigest(file.read)
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
  rescue EXIFR::MalformedJPEG
    @_exif ||= NullMetaData.new
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
  rescue NoMethodError
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
