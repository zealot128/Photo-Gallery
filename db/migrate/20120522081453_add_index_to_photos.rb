class AddIndexToPhotos < ActiveRecord::Migration
  def change
    add_index :photos, :shot_at
  end
end
