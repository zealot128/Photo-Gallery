# == Schema Information
#
# Table name: people
#
#  id         :integer          not null, primary key
#  name       :string
#  created_at :datetime         not null
#  updated_at :datetime         not null
#

class Person < ApplicationRecord
  has_many :image_faces
  has_many :base_files, through: :image_faces
end
