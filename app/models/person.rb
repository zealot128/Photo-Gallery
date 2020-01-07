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
  has_many :image_faces, dependent: :nullify
  has_many :base_files, through: :image_faces

  def as_json(opts = {})
    Rails.cache.fetch("person.#{id}.json", expires_in: 1.day) do
      preview = image_faces.order(Arel.sql("(bounding_box->>'width')::float desc, confidence desc")).first
      {
        id: id,
        name: name,
        faces: image_faces.count,
        preview: preview && preview.file.url
      }
    end
  end
end
