desc "Import all Pictures from ./import"
task :import => :environment do

  require "progressbar"
  user = User.first
  files = Dir[Rails.root.join("import/*")]
  pbar = ProgressBar.create(total: files.count)
  files.each do |file|
    pbar.increment
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
  Day.all.each do |day|
    day.update_me
  end
  pbar.finish
end


task :tidy_up => :environment do
  Day.joins("left join `photos` ON `photos`.`day_id` = `days`.`id`").group("days.id").having("count(day_id) = 0").map{|i|i.destroy}
end
