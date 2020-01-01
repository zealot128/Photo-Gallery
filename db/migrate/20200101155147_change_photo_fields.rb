class ChangePhotoFields < ActiveRecord::Migration[5.1]
  def change
    change_table :photos do |t|
      t.remove :video_processed
      t.remove :duration
      t.remove :file_size
      t.remove :aperture
      t.remove :meta_data
      t.remove :rekognition_faces_run
      t.remove :rekognition_labels_run
      t.remove :rekognition_ocr_run
      t.remove :error_on_processing
      t.jsonb :processing_flags
    end
  end
end
