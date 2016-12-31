class AddVideoProcessedToPhotos < ActiveRecord::Migration[5.0]
  def change
    add_column :photos, :video_processed, :boolean, default: false
  end
end
