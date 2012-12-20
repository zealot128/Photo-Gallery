class Rational
  def to_json(options={})
    to_s.to_json(options)
  end
end

class EXIFR::TIFF::Degrees
  def to_json(options={})
    to_a.to_json(options)
  end
end
