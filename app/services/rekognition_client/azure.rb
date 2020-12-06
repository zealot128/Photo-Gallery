require 'net/https'
require 'uri'
require 'json'

class RekognitionClient::Azure
  def azure_subscription_key
    ENV['AZURE_SUBSCRIPTION_KEY']
  end

  def azure_endpoint
    ENV['AZURE_ENDPOINT']
  end

  def rekognize_faces_in_photo(photo)
    photo_width = photo.meta_data.dig('exif', 'image_width')
    photo_height = photo.meta_data.dig('exif', 'image_height')
    faces = index_faces(photo)
    faces.face_records.each do |face|
      photo.image_faces.where(
        aws_id: face['faceId']
      ).first_or_create(
        bounding_box: {
          width: face.dig('faceRectangle', 'width').to_f / photo_width,
          height: face.dig('faceRectangle', 'height').to_f / photo_height,
          top: face.dig('faceRectangle', 'top').to_f / photo_height,
          left: face.dig('faceRectangle', 'left').to_f / photo_width,
        },
        confidence: 100
      )
    end
  end

  def delete_faces(aws_id)
  end

  def auto_assign_face(face)
  end

  def label_photo(photo)
  end

  def index_faces(photo)
    path = '/face/v1.0/detect'
    get_params = {
      recognitionModel: 'recognition_03',
      returnFaceId: 'true'
    }
    uri = URI.join(azure_endpoint, path)
    uri.query = get_params.to_query
    request = Net::HTTP::Post.new(uri.to_s)
    request['Content-Type'] = "application/octet-stream"
    request['Ocp-Apim-Subscription-Key'] = azure_subscription_key
    request.body = Photo.first.file.open.read

    response = Net::HTTP.start(uri.host, uri.port, use_ssl: uri.scheme == 'https') do |http|
      http.request (request)
    end
    JSON.load(response.body)
  end
end
