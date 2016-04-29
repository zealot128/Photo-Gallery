class V2::DaysController < ApplicationController
  before_filter :login_required

  def show
    @day = Day.find(params[:id])
    @photos = @day.photos.order('shot_at asc')
  end
end
