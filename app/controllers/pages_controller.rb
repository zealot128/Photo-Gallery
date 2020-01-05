class PagesController < ApplicationController
  def index
    @share = Share.where(name: "Public").first || Share.create!(name: "Public")
    @photos = @share.photos.order("shot_at desc")
    if current_user
      redirect_to '/v3'
    end
  end

  before_action :login_required, only: [:tag, :upload, :v3, :v3_faces]
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
    respond_to do |format|
      format.html
      format.sh {
        headers['Content-Disposition'] = 'attachment; filename="upload.sh"'
      }
    end
  end

  def v3
    render layout: false
  end

  def v3_faces
    render layout: false
  end
end
