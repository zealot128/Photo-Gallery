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
end
