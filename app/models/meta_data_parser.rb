class MetaDataParser
  def initialize(file_path)
    @path = file_path
    @exif = {}
    @exif_tool = MiniExiftool.new(@path, coord_format: "%+.6f")
  end

  def exif
    @exif_tool.as_json.transform_keys{|k| k.underscore }
  end

  def shot_at_date
    @exif_tool.date_time_original || @exif_tool.date_time
  end

  def gps
    {
      latitude: nil,
      longitude: nil
    }
  end

  def as_json(opts = {})
    @exif_tool.as_json.transform_keys{|k| k.underscore }.delete_if{|k,v| v.to_s['Binary data'] || k == 'user_comment' }
  end
end
