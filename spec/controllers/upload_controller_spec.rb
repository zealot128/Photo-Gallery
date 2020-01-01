require 'spec_helper'

describe UploadController do
  let(:picture) { fixture_file_upload('/tiger.jpg', 'image/jpeg') }

  specify "preconditions" do
    expect(User.count).to eq(0)
    expect(Photo.count).to eq(0)
  end
  specify "post without credentials should be 401" do
    post :create, params: { userfile: picture }
    expect(response.status).to eq(401)
  end
  context "successful transfers" do
    before :each do
      User.create! username: "test", password: "test123", email: "info@test.com", password_confirmation: "test123"
      request.env["HTTP_AUTHORIZATION"] = "Basic " + Base64.encode64("test:test123")
    end

    specify "post with valid credentials should work " do
      expect {
        post :create, params: { userfile: picture }
      }.to change(Photo, :count)
      expect(UploadLog.count).to eq(1)
      expect(response.status).to eq(200)
    end

    specify "authentication should be remembered" do
      request.env['REMOTE_ADDR'] = '1.2.3.4'
      post :create, params: { userfile: picture }

      User.first.tap do |u|
        expect(u.last_ip).to eq("1.2.3.4")
        expect(u.last_upload).to be > 1.minute.ago
      end
    end

    specify "user auth by ip" do
      request.env["REMOTE_ADDR"] = "1.2.3.4"
      User.first.enable_ip_based_login(request)
      expect(User.authenticate_by_ip(request)).to eq(User.first)
    end

    specify "authenication by ip should be invalid after some time" do
      request.env["REMOTE_ADDR"] = "1.2.3.4"
      User.first.enable_ip_based_login(request)
      User.first.update_attribute(:last_upload, 1.day.ago)

      expect(User.authenticate_by_ip(request)).to be_nil
    end

    specify "authentication with ip should work instead of HTTP AUTH" do
      request.env.delete "HTTP_AUTHORIZATION"

      request.env["REMOTE_ADDR"] = "1.2.3.4"
      User.first.enable_ip_based_login(request)

      expect {
        post :create, params: { userfile: picture }
      }.to change(Photo, :count)
      expect(response.status).to eq(200)
    end
  end
end
