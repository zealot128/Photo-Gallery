
require "progressbar"
def process(sql)
  total_count = sql.count
  pbar = ProgressBar.create(total: total_count)

  sql.find_each do |photo|
    pbar.increment
    photo.rekognize_labels
  end
end
sql = Photo.where('shot_at > ?', 1.year.ago).where('(select id from base_files_image_labels where base_file_id = id limit 1) is null').order('id desc');1
process(sql)
