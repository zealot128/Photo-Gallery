class CreateVideoThumbnails < ActiveRecord::Migration[5.0]
  def change
    create_table :video_thumbnails do |t|
      t.integer :video_id
      t.string :file
      t.integer :at_time
      t.index [:video_id, :at_time]
      t.index :video_id
    end
  end
end
