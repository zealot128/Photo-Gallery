class Photo::RecognizeFacesJob < ApplicationJob
  queue_as :default

  def perform(photo)
    return unless Setting['rekognition.faces.rekognition_collection']

    REKOGNITION_CLIENT.rekognize_faces_in_photo(photo)
    photo.processed_successfully!(:faces)
  end
end
