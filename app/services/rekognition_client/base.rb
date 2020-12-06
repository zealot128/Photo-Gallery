class RekognitionClient::Base
  AUTO_ASSIGN_THRESHOLD = Setting['rekognition.faces.auto_assign.threshold']
  AUTO_ASSIGN_MAX_FACES = Setting['rekognition.faces.auto_assign.max_faces']
  AUTO_ASSIGN_MIN_EXISTING_FACES = Setting['rekognition.faces.auto_assign.min_existing_faces']

  def rekognize_faces_in_photo(photo)
  end

  def auto_assign_face(face)
  end

  def label_photo(photo)
  end

  def ocr(photo)
  end

  def find_similar_faces(face, threshold:, max_faces:)
  end
end
