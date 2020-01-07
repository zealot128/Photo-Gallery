class Photo::RecognizeFacesJob < ApplicationJob
  queue_as :default

  def perform(photo)
    return unless Setting['rekognition.faces.rekognition_collection']

    faces = RekognitionClient.index_faces(photo)
    faces.face_records.each do |face|
      photo.image_faces.where(aws_id: face.face.face_id).first_or_create(bounding_box: face.face.bounding_box.as_json, confidence: face.face.confidence)
    end
    photo.processed_successfully!(:faces)
  end
end
