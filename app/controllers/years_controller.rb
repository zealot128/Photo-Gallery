class YearsController < ApplicationController
  before_filter :login_required
  def show
    @year = params[:year]
    @months_and_days = Day.grouped_by_day_and_month @year

    @month_names = ["","Jan","Feb","Mar", "Apr", "Mai", "Jun", "Jul", "Aug", "Sep","Okt", "Nov", "Dez"]
  end
end
