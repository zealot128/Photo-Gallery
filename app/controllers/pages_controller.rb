class PagesController < ApplicationController
  def index
    @share = Share.where(name: "Public").first || Share.create!(name: "Public")
    @host = "#{request.protocol}#{request.host_with_port}"
    @photos = @share.photos.order("shot_at desc").paginate(:page => params[:page], :per_page => 30)
    respond_to do |f|
      f.html
      f.atom {  render :layout => false }
    end
  end
end
