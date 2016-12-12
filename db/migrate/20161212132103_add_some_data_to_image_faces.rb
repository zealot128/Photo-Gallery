class AddSomeDataToImageFaces < ActiveRecord::Migration[5.0]
  def change
    add_column :image_faces, :confidence, :float
  end
end
