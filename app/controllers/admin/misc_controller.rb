class Admin::MiscController < ApplicationController
  before_action :admin_required
  def already_uploaded
    @check = ::AlreadyUploadCheck.new(params[:check])
    @check.date ||= 1.month.ago.to_date
  end

  def mark_as_deleted
    @files = BaseFile.where.not(mark_as_deleted_on: nil)
  end
end
