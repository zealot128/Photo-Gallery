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

    expect {
      photo = Photo.create_from_upload(File.open(picture.to_s), user)
    }.to_not change(Photo, :count)
  end

  specify "after saving should create or initialize respective day" do
    photo = nil
    expect {
      photo = Photo.create_from_upload(File.open(picture.to_s), user)
    }.to change(Day, :count)

    photo.day.should be_present
    Day.last.tap do |day|
      day.date.should == photo.shot_at.to_date
      day.year.should == photo.shot_at.year
    end
  end

  specify "Reusing created date" do
    d = Day.create date: Date.parse("2004-09-12")
    photo = nil
    expect {
      photo = Photo.create_from_upload(File.open(other_picture), user)
    }.to_not change(Day, :count)
    photo.day.should == d
    photo.reload.day.should == d
  end

  specify "Changing the date should move the file" do
    Photo.slow_callbacks = true
    photo = Photo.create_from_upload(File.open(picture.to_s), user)
    day = photo.day
    day.should_receive(:update_me)
    photo.update_attributes(:shot_at => Time.parse("2012-10-01 12:00"))
    photo.reload
    File.exists?(photo.file.path).should be_true
    Day.where(date: "2012-10-01").first.tap do |d|
      d.photos.should == [photo]
    end
  end

  specify 'EOS600d date format' do
    picture = "spec/fixtures/eos600.jpg"
    photo = Photo.create_from_upload(File.open(picture.to_s), user)
    photo.shot_at.should ==  DateTime.parse("2014-02-05T14:17:42+01:00")
  end

  specify 'Metadata' do
    picture = "spec/fixtures/eos600.jpg"
    photo = Photo.create_from_upload(File.open(picture.to_s), user)
    binding.pry
  end

  specify 'geocoding' do
    picture = "spec/fixtures/geocode.jpg"
    photo = Photo.create_from_upload(File.open(picture.to_s), user)
    photo.location.should == 'Hofheim - Wallau'
  end

  if Rails.application.config.features.ocr
    specify "OCR" do
      photo = Photo.create_from_upload(File.open("spec/fixtures/text.jpg"), user)
      photo.ocr
      photo.description.should include "Mietsteigerung"
    end
  end
end
