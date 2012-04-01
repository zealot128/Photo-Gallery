class AddShareHashToPhotos < ActiveRecord::Migration
  def change
    add_column :photos, :share_hash, :string
    add_index :photos, :share_hash

  end
end
