class RekognitionClient
  class << self
    def collection(max_results: 10)
      client.list_faces({
        collection_id: Rails.application.secrets.rekognition_collection,
        max_results: max_results,
      })
    rescue Aws::Rekognition::Errors::ResourceNotFoundException
      puts "Creating Face collection #{Rails.application.secrets.rekognition_collection}..."
      client.create_collection({
        collection_id: Rails.application.secrets.rekognition_collection,
      })
      collection(max_results: max_results)
    end

    def labels(photo, max_labels: 20, min_confidence: 40)
      resp = client.detect_labels({
        image: {
          s3_object: {
            bucket: Rails.application.secrets.fog['bucket'],
            name: photo.file.file.path,
          },
        },
        max_labels: max_labels,
        min_confidence: min_confidence,
      })
      resp
    end

    def index_faces(photo)
			client.index_faces({
        collection_id: Rails.application.secrets.rekognition_collection,
        image: {
          s3_object: {
            bucket: Rails.application.secrets.fog['bucket'],
            name: photo.file.file.path,
          },
        },
				external_image_id: photo.id.to_s,
				detection_attributes: ["DEFAULT"], # accepts DEFAULT, ALL
			})
    end

    def client
      @client ||= Aws::Rekognition::Client.new(CarrierWave::Uploader::Base.aws_credentials.merge(region: 'eu-west-1'))
    end
  end
end
