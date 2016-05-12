class Admin::MiscController < ApplicationController
  def already_uploaded
    @check = ::AlreadyUploadCheck.new(params[:check])
    @check.date ||= 1.month.ago.to_date
  end
end
