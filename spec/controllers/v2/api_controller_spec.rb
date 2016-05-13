require 'spec_helper'

describe V2::ApiController do
  before :each do
    @controller.stub :current_user => User.create!(username: "stefan",
                                                  password: "123123123",
                                                  email: "info@example.com",
                                                  password_confirmation: "123123123")
  end
  let :photo do
    Photo.slow_callbacks = false
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
      photo.shares.map(&:name).sort.should be == ['meetup2016', 'newshare123']
      photo.tag_list.should be == ['foobar']

      get :tags
      JSON.load(response.body).count.should be == 1

      get :shares
      JSON.load(response.body).count.should be == 2
    end
  end
end
