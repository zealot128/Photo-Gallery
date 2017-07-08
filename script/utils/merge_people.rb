# p1 and p2 are strings
# p1 will be kept and p2 mergt into
def merge_person(p1_name, p2_name)
  p1 = Person.find_by(name: p1_name)
  p2 = Person.find_by(name: p2_name)
  if p1 == p2
    raise ArgumentError, "Person #{p1_name} and #{p2_name} are the same"
  end
  puts "Merging #{p2.id} with #{p2.image_faces.count} faces into #{p1.id}"
  p2.image_faces.each do |face|
    face.update! person: p1
  end
  Person.find(p2.id).destroy
end
