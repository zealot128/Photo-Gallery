require 'spec_helper'

describe PhotosController do
  let :picture do
    fixture_file_upload('/tiger.jpg', 'image/jpeg')
  end
  specify "preconditions" do
    User.count.should == 0
    Photo.count.should == 0
  end

  specify "post without credentials should be 401" do
    post :create, :userfile => picture
    response.status.should == 401
  end

  context "successful transfers" do
    before :each do

      User.create! :username => "test", :password => "test123", :email => "info@test.com", :password_confirmation => "test123"
      request.env["HTTP_AUTHORIZATION"] = "Basic " + Base64::encode64("test:test123")
    end

    specify "post with valid credentials should work "do
      lambda {
        post :create, :userfile => picture
      }.should change(Photo, :count)
      response.status.should == 200
    end

    specify "authentication should be remembered" do

      request.env['REMOTE_ADDR'] = '1.2.3.4'
      post :create, :userfile => picture

      User.first.tap do |u|
        u.last_ip.should == "1.2.3.4"
        u.last_upload.should > 1.minute.ago
      end

    end

    specify "user auth by ip" do
      request.env["REMOTE_ADDR"] = "1.2.3.4"
      User.first.enable_ip_based_login(request)
      User.authenticate_by_ip(request).should == User.first
    end

    specify "authenication by ip should be invalid after some time" do
      request.env["REMOTE_ADDR"] = "1.2.3.4"
      User.first.enable_ip_based_login(request)
      User.first.update_attribute(:last_upload, 1.day.ago)

      User.authenticate_by_ip(request).should be_nil
    end

    specify "authentication with ip should work instead of HTTP AUTH" do
      request.env.delete "HTTP_AUTHORIZATION"

      request.env["REMOTE_ADDR"] = "1.2.3.4"
      User.first.enable_ip_based_login(request)

      lambda {
        post :create, :userfile => picture
      }.should change(Photo,:count)
      response.status.should == 200
    end


  end
end
