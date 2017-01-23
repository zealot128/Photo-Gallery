class AddErrorOnProcessingToPhotos < ActiveRecord::Migration[5.0]
  def change
    add_column :photos, :error_on_processing, :boolean, default: false
  end
end
