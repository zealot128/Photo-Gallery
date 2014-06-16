class RemoveShareHashFromPhotos < ActiveRecord::Migration
  def change
    remove_column :photos, :share_hash
  end
end
