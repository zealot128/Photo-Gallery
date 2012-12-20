class Rational
  def to_json(options={})
    to_s.to_json(options)
  end
end
