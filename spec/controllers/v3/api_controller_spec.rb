require 'spec_helper'
describe V3::ApiController do
  describe 'sign in' do
    specify 'sign in with token' do
      user = User.create!(username: "stefan",
                          password: "123123123",
                          email: "info@example.com",
                          password_confirmation: "123123123")
      post :sign_in, params: { username: "stefan", password: "123123123" }
      expect(response).to be_success
      expect(json['token']).to be_present
      expect(user.reload.app_tokens.count).to be == 1
    end

    specify 'sign in with token' do
      user = User.create!(username: "stefan",
                          password: "123123123",
                          email: "info@example.com",
                          password_confirmation: "123123123")
      token = user.app_tokens.create!

      request.headers['Authorization'] = "Bearer #{token.token}"
      get :photos, params: {}
      expect(response).to be_success
    end
  end

  describe 'signed in' do
    before :each do
      user = User.create!(username: "stefan",
                          password: "123123123",
                          email: "info@example.com",
                          password_confirmation: "123123123")
      allow(@controller).to receive(:current_user).and_return(user)
    end
    let(:photo) { Photo.new(shot_at: "2012-02-01 12:00:00", md5: '123').tap { |p| p.save!(validate: false) } }

    specify 'photos' do
      photo
      get :photos, params: { from: '2012-02-01', to: '2012-02-02', file_types: ['photo'] }
      expect(response).to be_success
      expect(json['data'].length).to be == 1
    end

    specify 'Camera model' do
      Rails.cache.clear
      # zero byte in gps_version_id
      photo.update(meta_data: {"model"=>"Canon EOS 600D", "gps_version_id"=>"\u0002\u0002\u0000\u0000"})

      get :exif
      expect(json['camera_models']).to be == [{ 'name' => 'Canon EOS 600D', 'count' => 1 }]

      get :photos, params: { camera_models: ['Canon EOS 600D'] }
    end
  end

  def json
    JSON.parse(response.body)
  end
end
