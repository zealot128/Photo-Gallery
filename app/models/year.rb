class Year < ActiveRecord::Base
  has_many :months
  has_many :days, through: :months
  has_many :photos, through: :days

  validates :name, presence: true, uniqueness: true

  def to_param
    name
  end

  def year
    name.to_i
  end
end
