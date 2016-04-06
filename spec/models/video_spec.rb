require "spec_helper"
describe Video do
  let(:video) { Rails.root.join('spec/fixtures/testvideo-wechat.mp4') }
  let(:user) { valid_user }

  it "should store the uniq by hash" do
    photo = Video.create_from_upload(File.open(video), user)
    photo.md5.should == Digest::MD5.hexdigest( video.read )
  end
end