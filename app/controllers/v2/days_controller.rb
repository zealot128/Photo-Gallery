class V2::DaysController < ApplicationController
  before_action :login_required

  def show
    @day = Day.find(params[:id])
    @previous_day = Day.where('date < ? ', @day.date).order('date desc').first
    @next_day = Day.where('date > ? ', @day.date).order('date asc').first
    @photos = @day.photos.order('shot_at asc')
  end
end
