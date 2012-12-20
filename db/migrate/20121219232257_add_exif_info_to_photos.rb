class AddExifInfoToPhotos < ActiveRecord::Migration
  def change
    add_column :photos, :exif_info, :text
  end
end
