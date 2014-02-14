desc "Import all Pictures from ./import"
task :import => :environment do

  require "progressbar"
  user = User.first
  Photo.slow_callbacks = false
  files = Dir[Rails.root.join("import/*")]
  pbar = ProgressBar.new("test", files.count +  500)
  files.each do |file|
    pbar.inc
begin
    photo = Photo.create_from_upload(File.open(file), user)
    if photo.new_record?
      puts "Error with #{file}:"
      puts photo.errors.full_messages
    end
rescue Exception => e
puts "Fehler mit #{file}:"
p e

end
  end
  Photo.slow_callbacks = true
  Day.all.each do |day|
    day.update_me
  end
  pbar.finish
end


task :tidy_up => :environment do
  Day.joins("left join `photos` ON `photos`.`day_id` = `days`.`id`").group("days.id").having("count(day_id) = 0").map{|i|i.destroy}
end
