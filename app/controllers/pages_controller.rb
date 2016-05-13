class PagesController < ApplicationController

  def index
    @share = Share.where(name: "Public").first || Share.create!(name: "Public")
    @photos = @share.photos.order("shot_at desc")
  end

  before_action :login_required, only: [:tag, :upload]
  def tag
    @tag = ActsAsTaggableOn::Tag.find(params[:id])
    @photos = BaseFile.tagged_with(@tag).order("shot_at desc")
  end

  def upload
  end

  private

end
