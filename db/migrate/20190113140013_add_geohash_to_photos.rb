class AddGeohashToPhotos < ActiveRecord::Migration[5.1]
  def change
    add_column :photos, :geohash, :integer
  end
end
