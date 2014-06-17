class RemoveExifInfoFromPhotos < ActiveRecord::Migration
  def change
    remove_column :photos, :exif_info
  end
end
