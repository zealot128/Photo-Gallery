class V2::MonthsController < ApplicationController
  before_filter :login_required

  def show
    @year = Year.find_by!(name: params[:id])
    @month = Month.find_by!(year_id: @year.id, month_number: params[:month])

    @next_month = Month.where('month_string > ?', @month.month_string).order('month_string').first
    @prev_month = Month.where('month_string < ?', @month.month_string).order('month_string').last
  end
end
