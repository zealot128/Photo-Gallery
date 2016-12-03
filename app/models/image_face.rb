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
end
