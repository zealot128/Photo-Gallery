class CreateImageFaces < ActiveRecord::Migration[5.0]
  def change
    create_table :image_faces do |t|
      t.json :bounding_box
      t.string :file
      t.integer :base_file_id, index: true
      t.integer :person_id, index: true
      t.uuid :aws_id

      t.timestamps
    end
  end
end
