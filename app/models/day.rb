class Day < ActiveRecord::Base
  validates_presence_of :date
  has_many :photos, class_name: 'BaseFile'
  belongs_to :month
  has_one :year, through: :month

  mount_uploader :montage, MontageUploader

  before_save do
    assign_month
  end

  def make_montage
    images = photos.order("shot_at asc").map{|i|i.file.versions[:thumb].path }
    image_args = Shellwords.shelljoin images
    width = [images.count, 30].min
    # TODO Tempfile
    out_file = Rails.root.join("tmp/", SecureRandom.hex(16) + ".jpg")
    command = "montage -geometry +0+0 -tile #{width}x #{image_args} #{out_file}"
    system command
    self.montage = File.open(out_file)
    self.save
    File.unlink out_file
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
    return destroy if self.photos.count == 0
    make_montage
    self.update_attribute :locations, photos.pluck(:location).reject(&:blank?).uniq.join(", ")
  end

  def assign_month
    if date_changed? or month.blank?
      self.month = Month.find_or_make(date)
    end
  end

end
