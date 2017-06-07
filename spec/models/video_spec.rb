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
#

require "spec_helper"
describe Video do
  let(:video) { Rails.root.join('spec/fixtures/testvideo-wechat.mp4') }
  let(:user) { valid_user }

  it "should store the uniq by hash" do
    photo = Video.create_from_upload(File.open(video), user)
    expect(photo.md5).to eq(Digest::MD5.hexdigest( video.read ))
  end
end
