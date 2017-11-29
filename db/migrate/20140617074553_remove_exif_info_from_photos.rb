class RemoveExifInfoFromPhotos < ActiveRecord::Migration[4.2]
  def change
    remove_column :photos, :exif_info
  end
end
