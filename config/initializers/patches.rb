class Rational
  def to_json(options={})
    to_s.to_json(options)
  end
end

class EXIFR::TIFF::Degrees
  def to_json(options={})
    to_a.map{|i|i.to_f}.to_json
  end
end
