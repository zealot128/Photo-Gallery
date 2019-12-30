require 'spec_helper'

describe V2::ApiController do
  before :each do
    user = User.create!(username: "stefan",
                        password: "123123123",
                        email: "info@example.com",
                        password_confirmation: "123123123")
    allow(@controller).to receive(:current_user).and_return(user)
  end
  let :photo do
    p = Photo.new shot_at: "2012-02-01"
    p.save! validate: false
    p
  end

  context "bulk update" do
    specify "New Share onthefly has higher priority" do
      share = Share.create(name: 'meetup2016')
      post :bulk_update, params: {
        file_ids: [photo.id],
        tag_ids: [], new_tag: 'foobar',
        share_ids: [share.id], new_share: 'newshare123'
      }
      expect(photo.shares.map(&:name).sort).to eq(['meetup2016', 'newshare123'])
      expect(photo.tag_list).to eq(['foobar'])

      get :tags
      expect(JSON.load(response.body).count).to eq(1)

      get :shares
      expect(JSON.load(response.body).count).to eq(2)
    end
  end
end
