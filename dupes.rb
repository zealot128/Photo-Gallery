base = Photo.where('shot_at > ?', 2.weeks.ago)
dupes = base.group(:file).having('count(file) > 1').count.keys

dupes.each do |file|
  keep, *delete = base.where(file: file)
  delete.each(&:delete)
  keep.save
  keep.day.update_me
end
