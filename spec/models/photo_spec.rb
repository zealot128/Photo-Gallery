require 'spec_helper'

describe Photo do

  let :picture do
    Rails.root.join("spec/fixtures/tiger.jpg")
  end

  let :user do
    valid_user
  end

  it "should store the uniq by hash" do
    photo = Photo.create_from_upload(File.open(picture.to_s), user)
    photo.md5.should == Digest::MD5.hexdigest( picture.read )
  end

  it "should validate by uniqness" do
    photo = Photo.create_from_upload(File.open(picture.to_s), user)

    lambda {
      photo = Photo.create_from_upload(File.open(picture.to_s), user)
    }.should_not change(Photo, :count)
  end
end
