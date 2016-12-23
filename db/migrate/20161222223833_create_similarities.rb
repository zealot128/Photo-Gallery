class CreateSimilarities < ActiveRecord::Migration[5.0]
  def change
    create_table :similarities do |t|
      t.integer :image_face1_id
      t.integer :image_face2_id
      t.float :similarity
      t.integer :created_at, limit: 8
      t.index [ :image_face2_id, :image_face1_id], unique: true
    end
  end
end
