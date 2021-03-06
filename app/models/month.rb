# == Schema Information
#
# Table name: months
#
#  id           :integer          not null, primary key
#  month_number :integer
#  year_id      :integer
#  created_at   :datetime         not null
#  updated_at   :datetime         not null
#  month_string :string
#

class Month < ActiveRecord::Base
  belongs_to :year, optional: true
  has_many :days
  has_many :photos, through: :days

  def to_param
    month_number.to_s
  end

  before_save do
    self.month_string ||= "#{year.name}-#{sprintf '%02d', month_number}"
  end

  def as_json(opts = {})
    super.merge('to_s' => to_s,
                'photo_count' => photos.count,
                'preview_photos' => photos.limit(10).as_json(opts),
                'url' => "/v2/years/#{year.name}/month/#{month_number}")
  end

  def self.find_or_make(date)
    year = Year.where(name: date.year).first_or_create
    where(month_number: date.month, year: year).first_or_create
  end

  def to_s
    "#{name} #{year.year}"
  end

  def name
    Date.new(year.year, month_number, 1).strftime "%B"
  end
end
