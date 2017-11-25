class PagesController < ApplicationController
  def index
    @share = Share.where(name: "Public").first || Share.create!(name: "Public")
    @photos = @share.photos.order("shot_at desc")
  end

  before_action :login_required, only: [:tag, :upload, :v3]
  def tag
    @tag = ActsAsTaggableOn::Tag.find(params[:id])
    @photos = BaseFile.tagged_with(@tag).order("shot_at desc")
  end

  def upload
    unless current_user.pseudo_password
      require 'generate_pseudo_password'
      current_user.pseudo_password = generate_pseudo_password
      current_user.save
    end
  end

  def v3
    render layout: false
  end

  private

end
