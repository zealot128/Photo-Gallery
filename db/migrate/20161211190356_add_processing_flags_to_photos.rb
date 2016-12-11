class AddProcessingFlagsToPhotos < ActiveRecord::Migration[5.0]
  def change
    change_table :photos do |t|
      t.boolean :rekognition_labels_run, default: false
      t.boolean :rekognition_faces_run, default: false
    end
  end

  def data
    Photo.where(id: Photo.joins(:image_faces).group('photos.id').pluck('photos.id')).update_all :rekognition_faces_run => true
    Photo.where(id: Photo.joins(:image_labels).group('photos.id').pluck('photos.id')).update_all :rekognition_labels_run => true
  end
end
