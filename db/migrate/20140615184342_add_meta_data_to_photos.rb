class AddMetaDataToPhotos < ActiveRecord::Migration[4.2]
  def change
    enable_extension :hstore
    add_column :photos, :meta_data, :hstore
  end
end
