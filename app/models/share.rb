class Share < ActiveRecord::Base
  before_create do
    self.token = SecureRandom.hex(24)
  end

  has_and_belongs_to_many :photos, :join_table => "photos_shares"
  validates_presence_of :name

  def to_param
    token
  end

  def grouped_photos
    photos.grouped_by_day_and_month
  end
end
