class Month < ActiveRecord::Base
  belongs_to :year
  has_many :days
  has_many :photos, through: :days

  def to_param
    month_number.to_s
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
