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
      super(val.to_json)
    end
  end

  def mime_type
    `file #{Shellwords.escape file.path} --mime-type -b`.strip
  end

  def get_fingerprint!
    unless file.cached?
      file.cache!
    end
    self.fingerprint = Phashion::Image.new(file.path).fingerprint rescue nil
  end

  def set_metadata
    return unless file.present?
    self.meta_data ||= {}
    self.meta_data = MetaDataParser.new(file.path).as_json
    self.aperture = case meta_data['f_number']
                    when %r{(\d+)/(\d+)} then Rational($1.to_i, $2.to_i).to_f
                    when nil, "" then nil
                    else meta_data['f_number'].to_f
                    end
    meta_data_will_change!
    if Photo.slow_callbacks
      set_top_colors
    end
    update_gps(save: false)
    save
  end

  def set_top_colors
    self.top_colors =  begin
                         r = `convert #{file.path} -posterize 5 -define histogram:unique-colors=true -colorspace HSL -format %c histogram:info:- | sort -n -r | head`
                         r.split("\n").map { |i|
                           Hash[
                             [:h, :s, :l].zip(i[/\(([^\)]*)\)/, 1].strip.split(/[, ]+/).map(&:to_i))
                           ]
                         }
                       end
  end

  def exif
    (self.meta_data || {}).except('fingerprint', 'top_colors')
  end

  def ocr
    return unless Setting['elasticsearch.enabled']
    path = Shellwords.escape file.path(:original)
    t = Tempfile.new([File.basename(path), ".tif"])

    Rails.logger.info `convert -depth 8 -colorspace Gray -auto-orient #{path} #{t.path}`
    unless $?.success?
      raise StandardError, "Error with converting grayscale image"
    end
    Rails.logger.info `tesseract #{t.path} #{t.path} -l deu 2>&1`
    unless $?.success?
      raise StandardError, "Error with tesseract-ocr"
    end
    self.description = File.read(t.path + ".txt")
    save
  end
end
