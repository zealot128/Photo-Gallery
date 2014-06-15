class AddMetaDataToPhotos < ActiveRecord::Migration
  def change
    enable_extension :hstore
    add_column :photos, :meta_data, :hstore
  end
end
