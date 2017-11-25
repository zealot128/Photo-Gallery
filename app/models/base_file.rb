# == Schema Information
#
# Table name: photos
#
#  id                     :integer          not null, primary key
#  shot_at                :datetime
#  lat                    :float
#  lng                    :float
#  user_id                :integer
#  created_at             :datetime         not null
#  updated_at             :datetime         not null
#  location               :string
#  md5                    :string
#  year                   :integer
#  month                  :integer
#  day_id                 :integer
#  caption                :string
#  description            :text
#  file                   :string
#  meta_data              :json
#  type                   :string
#  file_size              :integer
#  rekognition_labels_run :boolean          default(FALSE)
#  rekognition_faces_run  :boolean          default(FALSE)
#  aperture               :decimal(5, 2)
#  video_processed        :boolean          default(FALSE)
#  error_on_processing    :boolean          default(FALSE)
#  duration               :integer
#  mark_as_deleted_on     :datetime
#  rekognition_ocr_run    :boolean          default(FALSE)
#

class BaseFile < ApplicationRecord
  self.table_name = 'photos'
  has_and_belongs_to_many :image_labels, join_table: 'base_files_image_labels'
  has_many :image_faces, dependent: :destroy
  has_many :people, through: :image_faces
  has_many :likes
  has_many :liked_by, through: :likes, class_name: "User", source: :user
  has_one :ocr_result

  belongs_to :user
  belongs_to :day
  has_and_belongs_to_many :shares, join_table: "photos_shares", foreign_key: 'photo_id'
  acts_as_taggable
  scope :dates, -> { group(:shot_at).select(:shot_at).order("shot_at desc") }
  scope :visible, -> { where(mark_as_deleted_on: nil) }
  scope :deleted, -> { where.not(mark_as_deleted_on: nil) }
  validates :md5, uniqueness: true, presence: true
  cattr_accessor :slow_callbacks
  self.slow_callbacks = true

  reverse_geocoded_by :lat, :lng do |obj, results|
    if (geo = results.first)
      parts = [geo.city]
      parts << geo.address_components_of_type("establishment").first["short_name"] rescue nil
      parts << geo.address_components_of_type("sublocality").first["short_name"] rescue nil
      obj.update_attribute(:location, parts.join(" - "))
    end
  end

  before_validation do
    unless md5?
      if !(File.exist?(file.path)) && !file.cached?
        self.md5 ||= Digest::MD5.hexdigest(file.read.to_s)
      end
      self.md5 ||= Digest::MD5.file(file.path)
    end
  end

  before_save do
    if shot_at_changed? and shot_at_was.present?
      move_file_after_shot_at_changed
    end
    new_day = Day.date(shot_at)
    self.day = new_day
    if new_day != day and shot_at_was.present?
      move_file_after_shot_at_changed
    end
  end

  before_save do
    self.year = shot_at.year
    self.month = shot_at.month
    self.file_size ||= file.size
  end

  after_commit do
    if Photo.slow_callbacks
      day && day.update_me
      @old_day && @old_day.update_me
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

  def mark_as_delete!
    d = day
    update_column :mark_as_deleted_on, Time.zone.now
    d.update_me
  end

  def self.create_from_upload(file, current_user)
    path = file.try(:tempfile).try(:path) || file.try(:path)
    mime_type = `file #{Shellwords.escape(path)} --mime-type`.split(':').last.strip
    klass =
      case mime_type
      when %r{image/}, nil then Photo
      when %r{video/|mp4} then Video
      else raise NotImplementedError, "Unknown content type: #{mime_type}"
      end
    klass.create_from_upload(file, current_user)
  end

  def shot_at_without_timezone
    day.try(:date) || shot_at.to_date
  end

  def check_uniqueness
    valid?
  end

  def as_json(op = {})
    {
      id:                   id,
      type:                 type,
      location:             location,
      shot_at:              shot_at,
      shot_at_formatted:    I18n.l(shot_at, format: :short),
      file_size:            file_size,
      tag_ids:              tag_ids,
      tags:                 tags.loaded? ? tags.map(&:name) : tag_list,
      labels:               image_labels.loaded? ? image_labels.map(&:name) : image_labels.pluck(:name),
      share_ids:            share_ids,
      file_size_formatted:  ApplicationController.helpers.number_to_human_size(file_size),
      caption:              caption,
      description:          description,
      versions:             file.versions.map { |k, v| [k, v.url] }.to_h,
      download_url:         "/download/#{id}/#{attributes['file']}",
      marked_as_deleted:    !!mark_as_deleted_on,
      liked_by:             liked_by.map(&:username),
      exif:                 exif
    }
  end

  def move_file_after_shot_at_changed
    @old_day = day
    old = shot_at_was
    new = shot_at
    old_str = old.strftime("%Y-%m-%d")
    new_str = new.strftime("%Y-%m-%d")
    return if old_str == new_str

    ([[:original, file]] + file.versions.to_a).each do |_key, version|
      from = version.path.gsub(new_str, old_str).gsub(%r{/#{new.year}/}, "/#{old.year}/")
      to = version.path.gsub(old_str, new_str).gsub(%r{/#{old.year}/}, "/#{new.year}/")
      Rails.logger.info "[photo] Moving #{from} -> #{to}"
      Rails.logger.info "  #{from} exists? -> #{File.exist?(from)}"
      Rails.logger.info "  #{to}   exists? -> #{File.exist?(to)}"

      case version.file.class.to_s
      when 'CarrierWave::Storage::Fog::File'
        self.shot_at = old
        version.cache!
        self.shot_at = new
        version.store!
      else
        version.cache!
        version.store!
        if File.exist?(from)
          File.unlink(from)
        end
      end
    end
  end
end
