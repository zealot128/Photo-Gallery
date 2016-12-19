module FilterFormModel

  def date_parse(date)
    Chronic.parse(from, context: :past)
  end

  def parsed(file_size)
    return [nil, nil] if file_size.blank?

    min = nil
    max = nil

    parts = file_size.split(',').map(&:strip).reject(&:blank?)
    unit = "[\\d+,\\.kKmMgGbB ]+"
    parts.each do |part|
      case part
      when /^>=?(#{unit})/
        min = parse_number_with_unit($1)
      when /^<=?(#{unit})/
        max = parse_number_with_unit($1)
      when /^(#{unit})-(#{unit})/
        min = parse_number_with_unit($1)
        max = parse_number_with_unit($2)
      end
    end

    [ min, max]
  end

  def parse_number_with_unit(string)
    return nil if string.blank?
    string.gsub!(" ", "")
    string.gsub!(/bB/, "")
    multiplicator = 1
    multiplicator *= 1.kilobyte while string.sub!(/k/i,'')
    multiplicator *= 1.megabyte while string.sub!(/m/i,'')
    multiplicator *= 1.megabyte while string.sub!(/g/i,'')

    string.to_f * multiplicator
  end

end
