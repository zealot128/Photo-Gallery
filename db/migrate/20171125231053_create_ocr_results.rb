class CreateOcrResults < ActiveRecord::Migration[5.1]
  def change
    create_table :ocr_results do |t|
      t.integer :base_file_id, unique: true
      t.text :text

      t.timestamps
    end

    add_column :photos, :rekognition_ocr_run, :boolean, default: false
  end
end
