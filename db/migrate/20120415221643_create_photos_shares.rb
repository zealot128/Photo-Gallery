class CreatePhotosShares < ActiveRecord::Migration
  def change
    create_table :photos_shares, id: false do |t|
      t.references :share, :photo
    end
    add_index :photos_shares, [:share_id, :photo_id], unique: true
  end
end
