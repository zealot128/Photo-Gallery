class Share < ActiveRecord::Base
  scope :sorted, -> { order('lower(shares.name)') }
  before_create do
    self.token = SecureRandom.hex(24)
  end

  has_and_belongs_to_many :photos, join_table: "photos_shares", association_foreign_key: 'photo_id'
  validates_presence_of :name

  def to_param
    token
  end

  def grouped_photos
    photos.grouped_by_day_and_month
  end

  def to_s
    name
  end
end
