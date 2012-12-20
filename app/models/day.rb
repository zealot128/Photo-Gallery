class Day < ActiveRecord::Base
  attr_accessible :date, :year
  validates_presence_of :date
  has_many :photos
  has_attached_file :montage
  before_save do
    self.year ||= date.year
  end

  def make_montage
    images = photos.order("shot_at asc").map{|i|i.file.path(:thumb)}
    image_args = Shellwords.shelljoin images
    width = [images.count, 30].min
    out_file = Rails.root.join("tmp/", SecureRandom.hex(16) + ".jpg")
    command = "montage -geometry +0+0 -tile #{width}x #{image_args} #{out_file}"
    system command
    self.montage = File.open(out_file)
    self.save
    File.unlink out_file
  end

  def self.date(datetime)
    find_or_create_by_date datetime.to_date
  end

  def self.grouped_days(days)
    days.order("date desc").group_by do |i|
      i.date.month
    end
  end

  def self.grouped_by_day_and_month(year)
    grouped_days Day.where(year: year)
  end

  def update_me
    return destroy if self.photos.count == 0
    make_montage
    self.update_attribute :locations, photos.pluck(:location).reject(&:blank?).uniq.join(", ")
  end

end
