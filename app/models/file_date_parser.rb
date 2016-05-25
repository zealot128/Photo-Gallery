class FileDateParser
  attr_reader :file, :date

  def initialize(file:, exif_date:,user:)
    self.date = exif_date
    @file = file
    @user = user
  end

  def date=(val)
    if val && val.is_a?(String)
      case val
      # correction for exif from hd cam
      when /^(\d{4}):(\d{1,2}):(\d{1,2})/
        @date = Date.parse("#$1-#$2-#$3")
      else
        @date = Date.parse(val)
      end
    else
      @date = val
    end
  end

  def parsed_date
    if not date
      self.date = parse_date_from_filename
    end
    assumed_timezone = Time.zone
    # TODO move to user
    date.to_datetime.change(offset: date.in_time_zone(assumed_timezone).strftime("%z"))
  end

  def filename
    file.try(:original_filename) || File.basename(file.path)
  end

  def parse_date_from_filename
    if filename[/(\d{4})[\-_\.](\d{2})[\-_\.](\d{2})/]
      Date.parse "#$1-#$2-#$3"
    elsif filename[/(\d{4})(\d{2})(\d{2})/] and $1.to_i > 2000
      Date.parse "#$1-#$2-#$3"
    elsif filename[/(\d{10})/] and ($1.to_i > 2.years.ago.to_i) and ($1.to_i < 1.day.from_now.to_i)
      Time.at($1).to_date
    else
      Rails.logger.warn "No Date found for file #{filename}. taking mtime"
      file.mtime rescue Date.today
    end
  end
end
