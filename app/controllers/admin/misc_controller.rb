class Admin::MiscController < ApplicationController
  before_filter :admin_required
  def already_uploaded
    @check = ::AlreadyUploadCheck.new(params[:check])
    @check.date ||= 1.month.ago.to_date
  end
end
