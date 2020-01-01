# == Schema Information
#
# Table name: days
#
#  id         :integer          not null, primary key
#  date       :date
#  created_at :datetime
#  updated_at :datetime
#  locations  :string
#  montage    :string
#  month_id   :integer
#

class Day < ActiveRecord::Base
  validates :date, presence: true
  has_many :photos, class_name: 'BaseFile'
  belongs_to :month
  has_one :year, through: :month

  mount_uploader :montage, MontageUploader

  before_save do
    assign_month
  end

  def make_montage
    images = photos.visible.order("shot_at asc").select { |i| i.file_derivatives.present? }.map { |i| i.file_derivatives[:thumb].to_io }
    return if images.blank?

    width = [images.count, 15].min
    image_args = Shellwords.shelljoin(images.map(&:path))

    Tempfile.open(['montage', '.jpg']) do |f|
      f.binmode
      command = "montage -geometry +0+0 -tile #{width}x #{image_args} #{f.path}"
      system command

      self.montage = f
      save
    end
    images.map(&:close)
  end

  def self.date(datetime)
    where(date: datetime.to_date).first_or_create
  end

  def self.grouped_days(days)
    days.order("date desc").group_by do |i|
      i.date.month
    end
  end

  def self.grouped_by_day_and_month(year)
    grouped_days Day.where(year_id: Year.where(name: year).first)
  end

  def update_me
    return destroy if photos.count == 0

    make_montage
    update_attribute :locations, photos.pluck(:location).reject(&:blank?).uniq.join(", ")
  end

  def assign_month
    if date_changed? or month.blank?
      self.month = Month.find_or_make(date)
    end
  end
end
