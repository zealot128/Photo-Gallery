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

  specify "post with valid credentials should work "do
    User.create! :username => "test", :password => "test123", :email => "info@test.com", :password_confirmation => "test123"
    request.env["HTTP_AUTHORIZATION"] = "Basic " + Base64::encode64("test:test123")

    lambda {
      post :create, :userfile => picture
    }.should change(Photo, :count)
    response.status.should == 200
  end

end
