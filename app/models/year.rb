# == Schema Information
#
# Table name: years
#
#  id         :integer          not null, primary key
#  name       :string
#  created_at :datetime         not null
#  updated_at :datetime         not null
#

class Year < ActiveRecord::Base
  has_many :months
  has_many :days, through: :months
  has_many :photos, through: :days

  validates :name, presence: true, uniqueness: true

  def to_param
    name
  end

  def to_s
    year
  end

  def year
    name.to_i
  end

  def as_json(opts={})
    super.merge(photo_count: photos.count)
  end
end
