require "spec_helper"
RSpec.describe Video do
  include_context "active_job_inline"
  let(:path) { Rails.root.join('spec/fixtures/testvideo-wechat.mp4') }
  let(:user) { valid_user }

  it "should store the uniq by hash" do
    video = Video.create_from_upload(File.open(path), user)
    video.reload
    expect(video.md5).to eq(Digest::MD5.hexdigest(path.read))
    expect(video.file_derivatives).to be_present
    expect(video.file.metadata).to be_present
    expect(video.duration).to be > 0

    expect(
      video.as_json[:thumbnails]
    ).to be_present
  end

  it "should extract geo coordinates" do
    video = Video.create_from_upload(File.open("spec/fixtures/video_with_gps.mov"), user)
    video.reload
    expect(video.lat).to be_present
    expect(video.location).to be_present
  end
end
