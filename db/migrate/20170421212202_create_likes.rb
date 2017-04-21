class CreateLikes < ActiveRecord::Migration[5.1]
  def change
    create_table :likes do |t|
      t.belongs_to :user, foreign_key: true
      t.integer :base_file_id, index: true

      t.timestamps
    end
    add_index :likes, [:user_id, :base_file_id], unique: true
  end
end
