require 'spec_helper'
describe V3::ApiController do
  let(:user) {
    User.create!(username: "stefan",
                 password: "123123123",
                 email: "info@example.com",
                 password_confirmation: "123123123")
  }
  describe 'sign in' do
    specify 'sign in with token' do
      user
      post :sign_in, params: { username: "stefan", password: "123123123" }
      expect(response).to be_successful
      expect(json['token']).to be_present
      expect(user.reload.app_tokens.count).to be == 1
    end

    specify 'sign in with token' do
      token = user.app_tokens.create!

      request.headers['Authorization'] = "Bearer #{token.token}"
      get :photos, params: {}
      expect(response).to be_successful
    end
  end

  describe 'signed in' do
    before(:each) {
      allow(@controller).to receive(:current_user).and_return(user)
    }

    specify 'photos' do
      Photo.create_from_upload(File.open('spec/fixtures/aws.png'), user).tap(&:reload)
      get :photos, params: { from: '2016-05-17', to: '2016-05-18', file_types: ['photo'] }
      expect(response).to be_successful
      expect(json['data'].length).to be == 1
    end

    specify 'Camera model' do
      photo = nil
      perform_enqueued_jobs do
        photo = Photo.create_from_upload(File.open('spec/fixtures/somestuff.jpg'), user).tap(&:reload)
      end
      get :exif
      expect(json['camera_models']).to be == [{ 'name' => 'Canon EOS 20D', 'count' => 1 }]

      get :photos, params: { camera_models: ['Canon EOS 20D'] }
      expect(response).to be_successful
      expect(json['data'].length).to be == 1

      get :photos, params: { file_size: '< 1mb' }
      expect(response).to be_successful
      expect(json['data'].length).to be == 1

      get :photos, params: { aperture: '< 5.6' }
      expect(response).to be_successful
      expect(json['data'].length).to be == 1
    end
  end

  def json
    JSON.parse(response.body)
  end
end
