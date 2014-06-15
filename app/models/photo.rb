class Photo < ActiveRecord::Base
  mount_uploader :file, ImageUploader
  # has_attached_file :file, styles: {
  #   preview:  "300x300",
  #   thumb:  "30x30",
  #   medium: "500x500>",
  #   large:  "1000x1000>"
  # },
  # path:   ":rails_root/public/photos/:style/:date/:basename.:extension",
  # url:    "/photos/:style/:date/:basename.:extension",
  # convert_options: { all: '-auto-orient' }

  belongs_to :user
  belongs_to :day
  has_and_belongs_to_many :shares, :join_table => "photos_shares"
  acts_as_taggable
  serialize :exif_info, JSON
  scope :dates, group(:shot_at).select(:shot_at).order("shot_at desc")
  validates :md5, :uniqueness => true
  cattr_accessor :slow_callbacks
  self.slow_callbacks = true

  include PhotoMetadata

  if Rails.application.config.features.elasticsearch
    searchkick
    def search_data
      as_json.except(:exif).merge(exif).merge(top_colors: top_colors, fingerprint: fingerprint)
    end
  end


  attr_accessor :new_share

  before_validation do
    if new_share.present?
      share = Share.where(name: new_share).first_or_create
      self.shares << share unless self.shares.include?(share)
    end
  end

  before_save do
    self.share_hash = SecureRandom.hex(24)
    self.year = self.shot_at.year
    self.month = self.shot_at.month
  end

  before_save do
    if self.shot_at_changed? and self.shot_at_was.present?
      move_file_after_shot_at_changed
    end
    self.day = Day.date self.shot_at
  end

  before_validation on: :create do
    self.md5 = Digest::MD5.hexdigest(file.read)
  end

  after_save do
    if Photo.slow_callbacks
      self.day.update_me
      @old_day.update_me if @old_day
    end
  end

  def check_uniqueness
    valid?
  end

  def self.parse_date(file)
    meta = EXIFR::JPEG.new(file.path)
    date = meta.exif[:date_time] || meta.exif[:date_time_original] rescue nil
    if not date
      if file.original_filename[/(\d{4})[\-_\.](\d{2})[\-_\.](\d{2})/]
        date = Date.parse "#$1-#$2-#$3"
      else
        Rails.logger.warn "No Date found for file #{file.original_filename}. taking mtime"
        date = file.mtime rescue Date.today
      end
    end
    if date.is_a? String
      case date
      # correction for exif from hd cam
      when /^(\d{4}):(\d{1,2}):(\d{1,2})/
        date = Date.parse("#$1-#$2-#$3")
      else
        date = Date.parse(date)
      end
    end
    date
  end

  def self.create_from_upload(file, current_user)
    photo = Photo.new
    date = Photo.parse_date(file)
    meta = EXIFR::JPEG.new(file.path)
    if meta.gps
      photo.lat = meta.gps.latitude
      photo.lng = meta.gps.longitude
    end
    photo.shot_at = date
    photo.user = current_user
    photo.file = file
    photo.reverse_geocode
    photo.save
    photo
  end

  def modal_group
    shot_at.strftime("d%Y%m%d")
  end

  def rotate!(direction)
    degrees =  case direction.to_sym
               when :left
                 -90
               when :flip
                 180
               else
                 90
               end
    cmd = "mogrify -rotate #{degrees} #{Shellwords.escape(file.path(:original))}"
    `#{cmd}`
    self.exif_info['fingerprint'] = nil
    self.fingerprint
    file.reprocess!
  end

  def self.grouped_by_day_and_month

    days = all.group_by{|i|i.shot_at.to_date}.sort_by{|a,b| a}.reverse
    #  [datum, [items]] ...
    #  [month, [ [datum, items], ...

    days.group_by{|day, items| Date.parse day.strftime("%Y-%m-01")}
  end

  def self.grouped
    days = Photo.all.group_by{|i|i.shot_at.to_date}.sort_by{|a,b| a}.reverse
    #  [datum, [items]] ...
    #  [month, [ [datum, items], ...

    days.group_by{|day, items| Date.parse day.strftime("%Y-%m-01")}
  end

  # @deprecated
  def self.days_of_year(year)
    days = Photo.where(:year => year).
      group_by{|i|i.shot_at.to_date}.
      sort_by{|a,b| a}.reverse
    days.group_by{|day, items| day.month}
  end

  def self.years
    Photo.uniq.order("year desc").pluck(:year)
  end

  include ActionView::Helpers::NumberHelper

  def as_json(op={})
    {
      id:                   id,
      location:             location,
      shot_at:              shot_at,
      shot_at_formatted:    I18n.l(shot_at, format: :short),
      original:             file.url,
      file_size:            file.size,
      file_size_formatted:  number_to_human_size(file.size),
      caption:              caption,
      description:          description,
      exif:                 exif
    }
  end

  private

  def move_file_after_shot_at_changed
    @old_day = self.day
    old = shot_at_was.strftime("%Y-%m-%d")
    new = shot_at.strftime("%Y-%m-%d")
    file.versions.each do |key,version|
      from = version.path.gsub(new, old)
      to   = version.path
      Rails.logger.info "Moving #{from} -> #{to}"
      puts "Moving #{from} -> #{to}"
      puts "#{from} exists? -> #{File.exists?(from)}"
      puts "#{to}   exists? -> #{File.exists?(to)}"
      FileUtils.mkdir_p File.dirname(to)
      FileUtils.move from, to rescue false
    end
  end
end
