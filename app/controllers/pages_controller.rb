class PagesController < ApplicationController
  def index
    @share = Share.where(name: "Public").first || Share.create!(name: "Public")
    endless_pagination @share.photos.order("shot_at desc")
  end

  def tag
    @tag = ActsAsTaggableOn::Tag.find(params[:id])
    endless_pagination Photo.tagged_with(@tag).order("shot_at desc")
  end

  private

  def endless_pagination(relation)
    @host = "#{request.protocol}#{request.host_with_port}"
    @photos = relation.paginate(page: params[:page], per_page: 10)
    respond_to do |f|
      f.html
      f.json {
        render json: {
          status: "success",
          html: render_to_string(@photos, formats: [:html])
        }
      }
      f.atom {  render :index, layout: false }
    end
  end
end
