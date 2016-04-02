def generate_pseudo_password(length: 10)
  vowels = %w[a e i o u]
  consonants = [*'a'..'z'] - vowels

  vowel_prob = 0.5
  10.times.map {
    if vowel_prob > rand
      vowel_prob *= 0.9
      vowels.sample.first
    else
      vowel_prob /= 0.9
      consonants.sample.first
    end
  }.join
end
