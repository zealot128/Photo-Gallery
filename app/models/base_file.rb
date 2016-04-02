class BaseFile < ActiveRecord::Base
  self.table_name = 'photos'

  belongs_to :user
  belongs_to :day
  has_and_belongs_to_many :shares, join_table: "photos_shares", foreign_key: 'photo_id'
  acts_as_taggable
  scope :dates, -> { group(:shot_at).select(:shot_at).order("shot_at desc") }
  validates :md5, :uniqueness => true, presence: true
  cattr_accessor :slow_callbacks
  self.slow_callbacks = true

  attr_accessor :new_share

  before_validation on: :create do
    self.md5 = Digest::MD5.hexdigest(file.read)
  end

  before_validation do
    if new_share.present?
      share = Share.where(name: new_share).first_or_create
      self.shares << share unless self.shares.include?(share)
    end
  end

  before_save do
    self.year = self.shot_at.year
    self.month = self.shot_at.month
  end

  after_commit do
    if Photo.slow_callbacks
      self.day.update_me
      @old_day.update_me if @old_day
    end
  end

  after_destroy do
    day.update_me
  end

  def modal_group
    shot_at.strftime("d%Y%m%d")
  end

  def check_uniqueness
    valid?
  end

  def self.grouped_by_day_and_month
    days = all.sort_by{|i| i.shot_at }.group_by{|i|i.shot_at.to_date}.sort_by{|a,b| a}.reverse
    #  [datum, [items]] ...
    #  [month, [ [datum, items], ...
    days.group_by{|day, items| Date.parse day.strftime("%Y-%m-01")}
  end

end
