require File.expand_path('spec/spec_helper')

describe SharesController do
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

  let :share do
    Share.create! name: "123123"
  end
  context "bulk update" do
    specify "New Share onthefly has higher priority" do
      post :bulk_update, "photos"=>[photo.id], "choice"=>"share",
        "bulk"=>{"share_id"=>share.id, "tag_list"=>"bundeswehr"},
        "new_share_name"=>"bundeswehr"
      photo.shares.first.name.should == "bundeswehr"
    end

    specify "old Share choice" do
      post :bulk_update, "photos"=>[photo.id], "choice"=>"share",
        "bulk"=>{"share_id"=>share.id, "tag_list"=>"bundeswehr"},
        "new_share_name"=>""
      photo.shares.first.name.should == "123123"
    end

    specify "tag list" do
      post :bulk_update, "photos"=>[photo.id], "choice"=>"tag",
        "bulk"=>{"share_id"=>share.id, "tag"=>"bundeswehr"},
        "new_share_name"=>""
      photo.shares.count.should == 0
      photo.tags.first.name.should == "bundeswehr"
    end

    specify "no choice - error" do
      post :bulk_update, "photos"=>[photo.id], "choice"=>"",
        "bulk"=>{"share_id"=>share.id, "tag"=>"bundeswehr"},
        "new_share_name"=>""
      JSON.parse(response.body)["status"].should == "error"

    end

  end
end
