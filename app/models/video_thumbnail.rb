# == Schema Information
#
# Table name: video_thumbnails
#
#  id       :integer          not null, primary key
#  video_id :integer
#  file     :string
#  at_time  :integer
#

class VideoThumbnail < ApplicationRecord
  belongs_to :video
  scope :sorted, -> { order('at_time') }

  mount_uploader :file, VideoPreviewUploader

  after_create :recode!

  def recode!
    version = video.file.versions[:large]
    basename = File.basename version.path
    tf = Tempfile.new(['thumbnail', basename])
    tf.binmode
    tf.write version.read
    tf.flush
    self.file = tf
    save
  end
end
