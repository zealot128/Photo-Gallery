class V2::YearsController < ApplicationController
  before_filter :login_required
  def index
    @recent = BaseFile.order("created_at desc").limit(20)
    @years = Year.order('name desc')
  end

  def recent
    @recent = BaseFile.order("created_at desc").limit(30)
  end

  def show
    @year = Year.find_by!(name: params[:id])
    @days = @year.days.order('date desc').group_by{|i| i.date.month }
  end

  protected

  helper_method def last_upload
    BaseFile.maximum(:created_at)

  end
end
