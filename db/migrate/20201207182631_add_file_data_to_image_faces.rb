class AddFileDataToImageFaces < ActiveRecord::Migration[5.2]
  def change
    add_column :image_faces, :file_data, :jsonb
  end
end
