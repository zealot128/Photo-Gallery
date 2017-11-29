class CreateBaseFilesImageLabels < ActiveRecord::Migration[4.2]
  def change
    create_table :base_files_image_labels, :id => false do |t|
      t.references :base_file
      t.references :image_label
    end

    add_index :base_files_image_labels, [:base_file_id, :image_label_id],
      name: "base_files_image_labels_index",
      unique: true
  end
end
