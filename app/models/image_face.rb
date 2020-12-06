# == Schema Information
#
# Table name: image_faces
#
#  id           :integer          not null, primary key
#  bounding_box :json
#  file         :string
#  base_file_id :integer
#  person_id    :integer
#  aws_id       :uuid
#  created_at   :datetime         not null
#  updated_at   :datetime         not null
#  confidence   :float
#

class ImageFace < ApplicationRecord
  include Rewrite::FaceUploader::Attachment.new(:file)

  belongs_to :base_file
  belongs_to :person, optional: true

  after_create :crop_bounding_box
  after_create :auto_assign_person

  # For image face controller transient value
  attr_accessor :similarity

  after_destroy do
    REKOGNITION_CLIENT.delete_faces(aws_id)
  rescue StandardError => e
    p e unless Rails.env.production?
    nil
  end

  def crop_bounding_box
    image = nil
    base_file.file_derivatives[:large].download do |file|
      image = MiniMagick::Image.open(file.path)
      image_width = image.width
      image_height = image.height
      w = (bounding_box['width'] * image_width).round
      h = (bounding_box['height'] * image_height).round
      left = (bounding_box['left'] * image_width).round
      top = (bounding_box['top'] * image_height).round
      image.crop("#{w}x#{h}+#{left}+#{top}")
      image.resize 'x100>'
    end
    self.file = File.open(image.path)
    save
  end

  def auto_assign_person
    return unless Setting['rekognition.faces.auto_assign.enabled']
    return if person

    REKOGNITION_CLIENT.auto_assign_face(self)
  end

  def as_json(opts = {})
    {
      id: id,
      preview: file.url,
      bounding_box: bounding_box,
      similarity: similarity,
      confidence: confidence,
      person_id: person_id,
      file_id: base_file_id,
      person_name: person.try(:name)
    }
  end
end
