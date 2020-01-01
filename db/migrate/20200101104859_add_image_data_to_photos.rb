class AddImageDataToPhotos < ActiveRecord::Migration[5.1]
  def change
    add_column :photos, :file_data, :jsonb
  end
end
