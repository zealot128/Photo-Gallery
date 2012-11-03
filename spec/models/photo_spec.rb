require 'spec_helper'

describe Photo do

  let :picture do
    Rails.root.join("spec/fixtures/tiger.jpg")
  end
  let :other_picture do
    Rails.root.join("spec/fixtures/somestuff.jpg")
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

  specify "after saving should create or initialize respective day" do
    photo = nil
    lambda {
      photo = Photo.create_from_upload(File.open(picture.to_s), user)
    }.should change(Day, :count)

    photo.day.should be_present
    Day.last.tap do |day|
      day.date.should == photo.shot_at.to_date
      day.year.should == photo.shot_at.year
    end
  end

  specify "Reusing created date" do
    d = Day.create date: Date.parse("2004-09-11")
    photo = nil
    lambda {
      photo = Photo.create_from_upload(File.open(other_picture), user)
    }.should_not change(Day, :count)
    photo.day.should == d
    photo.reload.day.should == d
  end
end
