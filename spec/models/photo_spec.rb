require 'spec_helper'

RSpec.describe Photo do
  include_context "active_job_inline"
  let(:picture) { Rails.root.join("spec/fixtures/tiger.jpg") }
  let(:other_picture) { Rails.root.join("spec/fixtures/somestuff.jpg") }
  let(:user) { valid_user }

  it "should store the uniq by hash" do
    photo = Photo.create_from_upload(File.open(picture.to_s), user)
    expect(photo.id).to be_present

    photo.reload
    expect(photo.md5).to eq(Digest::MD5.hexdigest(picture.read))

    expect(File.exist?("public/photos/test/photos/original/2010/2010-04-10/tiger-62a1a217cc144075488a2399c175909d.jpg")).to be == true
    expect(File.exist?(photo.file.to_io)).to be == true

    expect(photo.file_derivatives).to be_present

    expect(photo.as_json).to be_present
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

    photo.reload

    expect(photo.day).to be_present
    Day.last.tap do |day|
      expect(day.date).to eq(photo.shot_at.to_date)
      expect(day.year.year).to eq(photo.shot_at.year)
    end
  end

  specify "Reusing created date" do
    d = Day.create date: Date.parse("2004-09-11")
    photo = nil
    expect {
      photo = Photo.create_from_upload(File.open(other_picture), user)
    }.to_not change(Day, :count)
    photo.reload
    expect(photo.day).to eq(d)
    expect(photo.reload.day).to eq(d)
  end

  specify "Changing the date should move the file" do
    photo = Photo.create_from_upload(File.open(picture.to_s), user)
    photo.reload
    day = photo.day
    photo.update(shot_at: Time.zone.parse("2012-10-01 12:00"))

    path = Photo.find(photo.id).file.to_io.path
    expect(File.exist?(path)).to be == true
    expect(path).to include 'photos/test/photos/original/2012/2012-10-01/tiger-62a1a217cc144075488a2399c175909d.jpg'

    old_path = path.gsub('/2012/', '/2010/').gsub('2012-10-01', day.date.to_s)

    expect(File.exist?(old_path)).to be == false

    Day.where(date: "2012-10-01").first.tap do |d|
      expect(d.photos).to eq([photo])
    end
  end

  specify 'EOS600d date format' do
    Time.zone = ActiveSupport::TimeZone[Rails.configuration.time_zone]
    picture = "spec/fixtures/eos600.jpg"
    photo = Photo.create_from_upload(File.open(picture.to_s), user)
    expect(photo.shot_at).to eq(Time.zone.parse("2014-02-05T14:17:42+01:00"))
  end

  specify 'Metadata' do
    picture = "spec/fixtures/eos600.jpg"
    photo = Photo.create_from_upload(File.open(picture.to_s), user)
    expect(photo.reload.as_json).to be_present
    expect(photo.aperture).to be == 2.6
    expect(photo.exif['model']).to eq('GT-N7100')
  end

  specify 'Mobile Phone format' do
    picture = 'spec/fixtures/IMG-20160508-WA0000.jpg'
    date = Photo.parse_date(File.open(picture), user)
    expect(date.to_date.to_s).to eq('2016-05-08')
  end

  specify 'Apple HEIF' do
    picture = 'spec/fixtures/IMG_1052.HEIC'
    date = Photo.parse_date(File.open(picture), user)
    expect(date.to_date.to_s).to eq('2019-12-27')

    photo = Photo.create_from_upload(File.open(picture.to_s), user)
    expect(photo.as_json).to be_present
    expect(photo.persisted?).to be_present
    expect(photo.reload.aperture).to be == 1.8
  end

  specify 'geocoding' do
    Geocoder.configure(lookup: :test)
    Geocoder::Lookup::Test.add_stub(
      [50.068056, 8.385000], [
        {
          'latitude' => 50.068056,
          'longitude' => 8.385000,
          'address' => "Rudolf-Diesel-Straße 3, 65719 Hofheim am Taunus, Germany",
          'city' => "Hofheim am Taunus",
        }
      ]
    )
    picture = "spec/fixtures/geocode.jpg"
    photo = Photo.create_from_upload(File.open(picture), user)
    expect(photo.reload.location).to eq('Hofheim am Taunus')
  end

  if Setting.tesseract_installed?
    specify "OCR" do
      photo = Photo.create_from_upload(File.open("spec/fixtures/text.jpg"), user)
      expect(photo.ocr_result.text).to include "Mietsteigerung"
    end
  end

  specify 'PNG upload' do
    picture = "spec/fixtures/aws.png"
    photo = Photo.create_from_upload(File.open(picture.to_s), user)

    expect(photo.persisted?).to be == true
    expect(photo.reload.exif).to be_present
  end

  specify 'rotate' do
    width = Vips::Image.new_from_file(picture.to_s).width
    photo = Photo.create_from_upload(File.open(picture.to_s), user)
    photo.reload
    photo.rotate!(:left)

    new_height = Vips::Image.new_from_file(photo.file.to_io.path).height
    expect(width).to be == new_height
  end

  describe 'AWS' do
    around do |ex|
      config = YAML.load_file('config/secrets.yml')['test']
      if config['fog'].blank? or config['fog']['aws_access_key_id'].blank?
        warn "Skipping AWS spec because no fog config found"
      else
        Setting['storage.original'] = 'aws'
        Setting['aws.access_key_id'] = Rails.application.secrets.fog[:aws_access_key_id]
        Setting['aws.access_key_secret'] = Rails.application.secrets.fog[:aws_secret_access_key]
        Setting['aws.region'] = Rails.application.secrets.fog[:region]
        Setting['aws.bucket'] = Rails.application.secrets.fog[:bucket]
        ex.run
      end
    ensure
      Setting['storage.original'] = 'file'
    end

    specify 'photo upload' do
      photo = Photo.create_from_upload(File.open(picture.to_s), user)
      photo.reload
      expect(photo.md5).to eq(Digest::MD5.hexdigest(picture.read))
      expect(photo.file_derivatives).to be_present
      expect(photo.as_json).to be_present

      expect(photo.file.url).to include "s3.eu-west-1.amazonaws.com"
      expect(
        Digest::MD5.file(Kernel.open(photo.file.url)).to_s
      ).to be == photo.md5
    end
  end

  specify 'Migration' do
    photo = Photo.create!(old_file: File.open(picture), shot_at: '2010-04-10T12:00', md5: Digest::MD5.hexdigest(picture.read))
    expect(File.exist?("public/test/photos/thumb/2010/2010-04-10/thumb_tiger.jpg")).to be == true
    photo.migrate!
    photo.reload

    expect(photo.file).to be_present
    expect(photo.file.to_io).to be_present
    expect(photo.file_derivatives[:thumb]).to be_present
    expect(photo.old_file.url(:thumb)).to be == photo.file_derivatives[:thumb].url
    expect(photo.file.url).to be == photo.file.url
  end
end
