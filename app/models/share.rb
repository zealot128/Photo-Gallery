# == Schema Information
#
# Table name: shares
#
#  id         :integer          not null, primary key
#  name       :string
#  type       :string
#  token      :string
#  created_at :datetime         not null
#  updated_at :datetime         not null
#  user_id    :integer
#

class Share < ActiveRecord::Base
  scope :sorted, -> { order('lower(shares.name)') }
  before_create do
    self.token = SecureRandom.hex(24)
  end

  has_and_belongs_to_many :photos, join_table: "photos_shares", association_foreign_key: 'photo_id'
  belongs_to :user
  validates :name, presence: true

  def to_param
    token
  end

  def grouped_photos
    photos.grouped_by_day_and_month
  end

  def file_size
    photos.map { |i| i.file_size.to_i }.sum
  end

  def to_s
    name
  end

  def as_json(opts = {})
    super.merge(
      'file_size' => file_size,
      'file_count' => photos.count
    )
  end
end
