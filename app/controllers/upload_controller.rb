class UploadController < ApplicationController
  protect_from_forgery except: :create
  before_filter :http_basic_auth

  def create
    Filelock "tmp/upload-#{@user.id}.lock", timeout: 180 do
      @photo = Photo.create_from_upload(params[:userfile], @user)
      @user.enable_ip_based_login request
      if @photo.new_record?
        render text: 'ALREADY_UPLOADED'
      else
        render text: 'OK'
      end
    end
  end

  protected

  def http_basic_auth
    if params[:token]
      return @user = User.where(token: params[:token]).first!
    end
    if by_ip       = User.authenticate_by_ip(request)
      return @user = by_ip
    end
    authenticate_or_request_with_http_basic do |username, password|
      if by_username = User.authenticate(username, password)
        @user = by_username
        true
      else
        false
      end
    end
  end
end
