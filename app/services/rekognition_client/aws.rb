class RekognitionClient::Aws
  class << self
    def rekognize_faces_in_photo(photo)
      faces = index_faces(photo)
      faces.face_records.each do |face|
        photo.image_faces.where(aws_id: face.face.face_id).first_or_create(bounding_box: face.face.bounding_box.as_json, confidence: face.face.confidence)
      end
    end

    def label_photo(photo)
      aws_labels = labels(photo)
      aws_labels.labels.each do |aws_label|
        photo.image_labels.where(name: aws_label.name).first ||
          begin
          label = ImageLabel.where(name: aws_label.name).first_or_create
          photo.image_labels << label
        end
      end
    end

    def find_similar_faces(face, threshold:, max_faces:)
      similar = search_faces(face.aws_id, threshold: threshold.to_i, max_faces: max_faces.to_i)
      out = similar.face_matches.map { |i| [i.face.face_id, [i.similarity, i.face.confidence]] }.to_h
      ImageFace.where(aws_id: out.keys).tap { |faces|
        faces.each do |face|
          face.similarity, confidence = out[face.aws_id]
          if face.confidence.nil?
            face.confidence = confidence
            face.save
          end
        end
      }.sort_by { |a| -(a.similarity || 0) }
    end

    def rekognition_collection
      Setting['rekognition.faces.rekognition_collection'] || (raise ArgumentError, "No rekognition_collection set, please run with AWS_REKOGNITION_COLLECTION")
    end

    def auto_assign_face(face)
      similar = search_faces(face.aws_id, threshold: RekognitionClient::Base::AUTO_ASSIGN_THRESHOLD, max_faces: RekognitionClient::Base::AUTO_ASSIGN_MAX_FACES)
      if similar.face_matches.count >= RekognitionClient::Base::AUTO_ASSIGN_MIN_EXISTING_FACES
        aws_ids = similar.face_matches.map { |i| i.face.face_id }
        face_histogram = ImageFace.unscoped.where(aws_id: aws_ids).map(&:person_id).compact.group_by(&:itself).map { |a, b| [a, b.count] }.to_h
        if face_histogram.length == 1 && face_histogram.values.first >= RekognitionClient::Base::AUTO_ASSIGN_MIN_EXISTING_FACES
          person_id = face_histogram.keys.first
          face.update person_id: person_id
        end
      end
    end

    def collection(max_results: 100, next_token: nil)
      client.list_faces({
        collection_id: rekognition_collection,
        max_results: max_results,
        next_token: next_token
      }.delete_if { |_k, v| v.nil? })
    rescue Aws::Rekognition::Errors::ResourceNotFoundException
      create_collection
      collection(max_results: max_results)
    end

    def create_collection
      Rails.logger.info "Creating Face collection #{rekognition_collection}..."
      client.create_collection(
        collection_id: rekognition_collection
      )
    end

    def labels(photo, max_labels: Setting['rekognition.labels.max_labels'], min_confidence: Setting['rekognition.labels.min_confidence'])
      return [] unless photo.file.storage_key == :aws

      resp = client.detect_labels(
        image: image_or_s3(photo),
        max_labels: max_labels,
        min_confidence: min_confidence
      )
      resp
    end

    def ocr(photo)
      response = client.detect_text(image_or_s3(photo))
      response.text_detections.map(&:detected_text).join(' ')
    end

    def image_or_s3(photo)
      if photo.file.storage_key == :AWS
        {
          s3_object: {
            bucket: Setting['aws.bucket'],
            name: photo.file.id,
          }
        }
      else
        large = photo.file_attacher.derivatives[:large]
        out = nil
        large.open do
          file = Setting.image_processing.
            source(large.tempfile).
            convert("jpg").
            resize_to_limit!(1000, 1000)
          out = file.read
        end
        {
          bytes: out
        }
      end
    end

    def index_faces(photo)
      client.index_faces(
        collection_id: rekognition_collection,
        image: image_or_s3(photo),
        external_image_id: photo.id.to_s,
        detection_attributes: ["DEFAULT"] # accepts DEFAULT, ALL
      )
    rescue Aws::Rekognition::Errors::ResourceNotFoundException
      create_collection
      retry
    end

    def search_faces(face_id, max_faces: 500, threshold: 80.0)
      client.search_faces(
        collection_id: rekognition_collection,
        face_id: face_id.to_s,
        max_faces: max_faces,
        face_match_threshold: threshold
      )
    end

    def delete_faces(*face_ids)
      client.delete_faces(
        collection_id: rekognition_collection,
        face_ids: face_ids.map(&:to_s) # required
      )
    end

    def client
      @client ||= Aws::Rekognition::Client.new(
        access_key_id: Setting['aws.access_key_id'],
        secret_access_key: Setting['aws.access_key_secret'],
        region: Setting['aws.region']
      )
    end
  end
end
