class RemoveShareHashFromPhotos < ActiveRecord::Migration[4.2]
  def change
    remove_column :photos, :share_hash
  end
end
