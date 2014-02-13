require "spec_helper"
describe PdfFile do
  let :pdf do
    Rails.root.join("spec/fixtures/file.pdf")
  end

  it 'should create pdf' do
    pdf = PdfFile.create_from_upload(File.open(pdf.to_s), user)
    pdf.md5.should == Digest::MD5.hexdigest( pdf.read )
    pdf.day.should be_present
  end

  it 'should have a preview image'


end
