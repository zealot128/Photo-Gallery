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
#

class ImageFace < ApplicationRecord
  belongs_to :base_file
  belongs_to :people

  after_create :crop_bounding_box
  mount_uploader :file, MontageUploader

  def crop_bounding_box
    version = base_file.file.versions[:medium]
    version.cache!
    image = MiniMagick::Image.new(version.path)
    image_width = image.width
    image_height = image.height
    w = (bounding_box['width'] * image_width).round
    h = (bounding_box['height'] * image_height).round
    left = (bounding_box['left'] * image_width).round
    top = (bounding_box['top'] * image_height).round
    image.crop("#{w}x#{h}+#{left}+#{top}")
    self.file = File.open(image.path)
    self.save
  end
end
