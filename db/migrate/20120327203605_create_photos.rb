class CreatePhotos < ActiveRecord::Migration
  def change
    create_table :photos do |t|
      t.datetime :shot_at
      t.decimal :lat
      t.decimal :lng
      t.references :user

      t.timestamps
    end
  end
end
