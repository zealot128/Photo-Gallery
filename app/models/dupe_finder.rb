class DupeFinder
  def self.run
    dupes = Photo.group(:file, :day_id).having('count(file) > 1').count.keys

    dupes.each do |file,day_id|
      keep, *delete = Photo.where(file: file, day_id: day_id)
      delete.each(&:delete)
      keep.save
      keep.day.update_me
    end
  end
end
