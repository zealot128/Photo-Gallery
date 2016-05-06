class V2::MonthsController < ApplicationController
  before_filter :login_required

  def show
    @year = Year.find_by!(name: params[:id])
    @month = Month.find_by!(year_id: @year.id, month_number: params[:month])
  end
end
