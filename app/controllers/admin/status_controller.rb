class Admin::StatusController < ApplicationController
  before_action :admin_required

  def index
    @checks = SystemStatus.new.checks
    respond_to do |f|
      f.html
      f.json {
        render json: { checks: @checks }
      }
    end
  end
end
