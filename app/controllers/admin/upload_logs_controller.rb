class Admin::UploadLogsController < ApplicationController
  before_action :admin_required

  def index
    @logs = UploadLog.order('created_at desc').limit(100)
  end
end
