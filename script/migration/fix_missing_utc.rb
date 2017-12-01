# Photo.all.select{|i| i.day.date != i.shot_at.utc.to_date }
# missing = maybe.reject{|i| i.file.read rescue false }
# ids = missing.map(&:id)

ids = [12654, 12823, 17750, 21986, 31849, 12286, 12523, 16384, 19454, 27477,
       20253, 16853, 11589, 11695, 12336, 13102, 12758, 12927, 13006, 13058,
       13077, 13436, 13711, 13867, 14003, 14084, 14596, 14235, 14244, 14312,
       14351, 14633, 14877, 14929, 15218, 15297, 16822, 15517, 15737, 17080,
       16090, 16204, 17057, 16377, 16463, 17261, 17320, 18924, 17654, 18131,
       18160, 18200, 18325, 18457, 18620, 18634, 18950, 18953, 19335, 19344,
       19368, 19403, 19615, 19904]
ids.each do |id|
  missing = BaseFile.find(id)
  before_day = missing.shot_at
  day = Day.date(missing.shot_at.utc.to_date)
  missing.update_column :day_id, day.id
  missing.reload

  result = begin
             missing.file.read && true
           rescue Aws::S3::Errors::NoSuchKey
             false
           end
  puts "File=#{missing.id} shot_at=#{missing.shot_at} from=#{before_day.to_s}"
  puts "  Result: #{result}"
end
