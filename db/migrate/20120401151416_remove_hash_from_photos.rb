class RemoveHashFromPhotos < ActiveRecord::Migration
  def change
    remove_column :photos, :hash
  end
end
