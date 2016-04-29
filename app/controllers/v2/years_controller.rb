class V2::YearsController < ApplicationController
  before_filter :login_required
  def index
    @years = Year.order('name desc')
  end

  def show
    @year = Year.find_by!(name: params[:id])
    @days = @year.days.order('date desc').group_by{|i| i.date.month }
  end
end
