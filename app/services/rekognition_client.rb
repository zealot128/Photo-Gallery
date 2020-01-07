class RekognitionClient
  class << self
    def rekognition_collection
      Setting['rekognition.faces.rekognition_collection']
    end

    def collection(max_results: 100, next_token: nil)
      client.list_faces({
        collection_id: rekognition_collection,
        max_results: max_results,
        next_token: next_token
      }.delete_if { |_k, v| v.nil? })
    rescue Aws::Rekognition::Errors::ResourceNotFoundException
      Rails.logger.info "Creating Face collection #{rekognition_collection}..."
      client.create_collection(
        collection_id: rekognition_collection
      )
      collection(max_results: max_results)
    end

    def labels(photo, max_labels: Setting['rekognition.labels.max_labels'], min_confidence: Setting['rekognition.labels.min_confidence'])
      return [] unless photo.file.storage_key == :aws

      resp = client.detect_labels(
        image: {
          s3_object: {
            bucket: Setting['aws.bucket'],
            name: photo.file.id,
          },
        },
        max_labels: max_labels,
        min_confidence: min_confidence
      )
      resp
    end

    def ocr(photo)
      client.detect_text(image: {
                           s3_object: {
                             bucket: Setting['aws.bucket'],
                             name: photo.file.id,
                           },
                         })
    end

    def index_faces(photo)
      client.index_faces(
        collection_id: rekognition_collection,
        image: {
          s3_object: {
            bucket: Setting['aws.bucket'],
            name: photo.file.id,
          },
        },
        external_image_id: photo.id.to_s,
        detection_attributes: ["DEFAULT"] # accepts DEFAULT, ALL
      )
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
      @client ||= Aws::Rekognition::Client.new(CarrierWave::Uploader::Base.aws_credentials)
    end
  end
end
