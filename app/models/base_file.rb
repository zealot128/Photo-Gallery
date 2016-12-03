# == Schema Information
#
# Table name: photos
#
#  id          :integer          not null, primary key
#  shot_at     :datetime
#  lat         :float
#  lng         :float
#  user_id     :integer
#  created_at  :datetime         not null
#  updated_at  :datetime         not null
#  location    :string
#  md5         :string
#  year        :integer
#  month       :integer
#  day_id      :integer
#  caption     :string
#  description :text
#  file        :string
#  meta_data   :json
#  type        :string
#  file_size   :integer
#

class BaseFile < ActiveRecord::Base
  self.table_name = 'photos'
  has_and_belongs_to_many :image_labels, join_table: 'base_files_image_labels'
  has_many :image_faces
  has_many :people, through: :image_faces

  belongs_to :user
  belongs_to :day
  has_and_belongs_to_many :shares, join_table: "photos_shares", foreign_key: 'photo_id'
  acts_as_taggable
  scope :dates, -> { group(:shot_at).select(:shot_at).order("shot_at desc") }
  validates :md5, :uniqueness => true, presence: true
  cattr_accessor :slow_callbacks
  self.slow_callbacks = true

  reverse_geocoded_by :lat, :lng do |obj,results|
    if geo = results.first
      parts = [geo.city]
      parts << geo.address_components_of_type("establishment").first["short_name"]  rescue nil
      parts << geo.address_components_of_type("sublocality").first["short_name"] rescue nil
      obj.update_attribute(:location, parts.join(" - "))
    end
  end

  before_validation do
    if !md5?
      if !(File.exists?(file.path)) && !file.cached? #File already gone
        self.md5 ||= Digest::MD5.hexdigest file.read.to_s
      end
      self.md5 ||= Digest::MD5.file(file.path)
    end
  end

  before_save do
    if (self.shot_at_changed? and self.shot_at_was.present?)
      move_file_after_shot_at_changed
    end
    new_day = Day.date(self.shot_at)
    if new_day != day and shot_at_was.present?
      self.day = new_day
      move_file_after_shot_at_changed
    else
      self.day = new_day
    end
  end

  before_save do
    self.year = self.shot_at.year
    self.month = self.shot_at.month
    self.file_size = self.file.size
  end

  after_commit do
    if Photo.slow_callbacks
      day && day.update_me
      @old_day.update_me if @old_day
    end
  end

  after_destroy do
    day && day.update_me
  end

  def retrieve_and_reprocess(&block)
    file.cache_stored_file!
    file.retrieve_from_cache!(file.cache_name)
    yield(file.file)
    file.recreate_versions!
  end

  def self.create_from_upload(file, current_user)
    path = file.try(:tempfile).try(:path) || file.path
    mime_type = `file #{Shellwords.escape(path)} --mime-type`.split(':').last.strip
    klass =
      case mime_type
      when %r{image/}, nil then Photo
      when %r{video/|mp4} then Video
      else raise NotImplementedError.new("Unknown content type: #{mime_type}")
      end
    klass.create_from_upload(file,current_user)
  end

  def shot_at_without_timezone
    self.day.try(:date) || shot_at.to_date
  end

  def check_uniqueness
    valid?
  end

  def as_json(op={})
    {
      id:                   id,
      type:                 type,
      location:             location,
      shot_at:              shot_at,
      shot_at_formatted:    I18n.l(shot_at, format: :short),
      file_size:            file_size,
      tag_ids:              tag_ids,
      tags:                 tag_list,
      labels:               image_labels.pluck(:name),
      share_ids:            share_ids,
      file_size_formatted:  ApplicationController.helpers.number_to_human_size(file_size),
      caption:              caption,
      description:          description,
      versions:             file.versions.map{|k,v| [k,v.url] }.to_h,
      download_url:         "/download/#{id}/#{attributes['file']}",
      exif:                 exif
    }
  end

  def move_file_after_shot_at_changed
    @old_day = self.day
    old = shot_at_was
    new = shot_at
    old_str = old.strftime("%Y-%m-%d")
    new_str = new.strftime("%Y-%m-%d")
    return if old_str == new_str

    ([[:original, file]] + file.versions.to_a ).each do |key,version|
      from = version.path.gsub(new_str, old_str).gsub(%r{/#{new.year.to_s}/}, "/#{old.year.to_s}/")
      to = version.path.gsub(old_str, new_str).gsub(%r{/#{old.year.to_s}/}, "/#{new.year.to_s}/")
      Rails.logger.info "[photo] Moving #{from} -> #{to}"
      Rails.logger.info "  #{from} exists? -> #{File.exists?(from)}"
      Rails.logger.info "  #{to}   exists? -> #{File.exists?(to)}"

      case version.file.class.to_s
      when 'CarrierWave::Storage::Fog::File'
        self.shot_at = old
        version.cache!
        self.shot_at = new
        version.store!
      else
        version.cache!
        version.store!
      end
    end
  end

end
