desc "Import all Pictures from ./import"
task :import => :environment do

  require "progressbar"
  user = User.first
  files = Dir[Rails.root.join("import/*")]
  pbar = ProgressBar.new("test", files.count)
  files.each do |file|
    pbar.inc
    photo = Photo.create_from_upload(File.open(file), user)
    if photo.new_record?
      puts "Error with #{file}:"
      puts photo.errors.full_messages
    end
  end
  pbar.finish
end


task :tidy_up => :environment do
  Day.joins("left join `photos` ON `photos`.`day_id` = `days`.`id`").group("days.id").having("count(day_id) = 0").map{|i|i.destroy}
end
