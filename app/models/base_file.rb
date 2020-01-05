# == Schema Information
#
# Table name: photos
#
#  id                 :integer          not null, primary key
#  shot_at            :datetime
#  lat                :float
#  lng                :float
#  user_id            :integer
#  created_at         :datetime
#  updated_at         :datetime
#  location           :string
#  md5                :string
#  year               :integer
#  month              :integer
#  day_id             :integer
#  caption            :string
#  description        :text
#  old_file           :string
#  type               :string
#  mark_as_deleted_on :datetime
#  geohash            :integer
#  fingerprint        :string
#  file_data          :jsonb
#  processing_flags   :jsonb
#

class BaseFile < ApplicationRecord
  self.table_name = 'photos'

  include ShrineMigration

  has_and_belongs_to_many :image_labels, join_table: 'base_files_image_labels'
  has_many :image_faces, dependent: :destroy
  has_many :people, through: :image_faces
  has_many :likes, dependent: :destroy
  has_many :liked_by, through: :likes, class_name: "User", source: :user
  has_one :ocr_result, dependent: :destroy
  belongs_to :user, optional: true
  belongs_to :day, optional: true
  has_and_belongs_to_many :shares, join_table: "photos_shares", foreign_key: 'photo_id'
  acts_as_taggable
  scope :dates, -> { group(:shot_at).select(:shot_at).order("shot_at desc") }
  scope :visible, -> { where(mark_as_deleted_on: nil) }
  scope :deleted, -> { where.not(mark_as_deleted_on: nil) }
  validates :md5, uniqueness: true, presence: true

  reverse_geocoded_by :lat, :lng do |obj, results|
    if (geo = results.first)
      parts = [geo.city]
      begin
        parts << geo.address_components_of_type("establishment").first["short_name"]
      rescue StandardError
        nil
      end
      begin
        parts << geo.address_components_of_type("sublocality").first["short_name"]
      rescue StandardError
        nil
      end
      obj.update_attribute(:location, parts.join(" - "))
    end
  end

  before_validation do
    self.md5 ||= file_data.dig('metadata', 'md5')
    self.md5 ||= Digest::MD5.file(file.to_io).to_s
  end

  before_save do
    self.year = shot_at.year
    self.month = shot_at.month
  end

  after_save do
    new_day = Day.date(shot_at)
    old_day = day || new_day

    next if file_derivatives.blank?

    if (saved_change_to_shot_at? and shot_at_before_last_save.present?) || new_day != day
      update_column(:day_id, new_day.id)

      BaseFile::MoveDayJob.set(wait: 5.seconds).perform_later(self, old_day, new_day)
    end
  end

  after_destroy do
    day&.update_me_async
  end

  def mark_as_delete!
    update_column :mark_as_deleted_on, Time.zone.now
    day&.update_me_async
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
    day.try(:date) || shot_at.utc.to_date
  end

  def check_uniqueness
    valid?
  end

  def as_json(options = {})
    {
      id: id,
      type: type,
      location: location,
      shot_at: shot_at,
      shot_at_formatted: I18n.l(shot_at, format: :short),
      file_size: file_size,
      tag_ids: tag_ids,
      tags: tags.loaded? ? tags.map(&:name) : tag_list,
      labels: image_labels.loaded? ? image_labels.map(&:name) : image_labels.pluck(:name),
      share_ids: share_ids,
      file_size_formatted: ApplicationController.helpers.number_to_human_size(file_size),
      caption: caption,
      description: description,
      versions: file_derivatives.except(:screenshots).transform_values(&:url),
      download_url: "/download/#{id}/#{attributes['file']}",
      marked_as_deleted: !!mark_as_deleted_on,
      liked_by: liked_by.map(&:username),
      exif: exif
    }
  end

  def processed?(type)
    processing_flags&.[](type.to_s)
  end

  def processed_successfully!(type)
    self.processing_flags ||= {}
    self.processing_flags[type.to_s] = true
    update_column :processing_flags, processing_flags
  end

  def meta_data
    file.metadata
  end

  delegate :size, to: :file, prefix: true
end
