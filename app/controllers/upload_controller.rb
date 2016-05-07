class UploadController < ApplicationController
  skip_before_filter :verify_authenticity_token
  before_filter :http_basic_auth

  def create
    Filelock "tmp/upload-#{@user.id}.lock", timeout: 180 do
      @photo = BaseFile.create_from_upload(params[:userfile] || params[:upfile], @user)
      @user.enable_ip_based_login request
      if @photo.new_record?
        render text: "ALREADY_UPLOADED:: #{@photo.errors.full_messages}", status: 409
      else
        render text: 'OK'
      end
    end
  end

  def test
    render text: ''
  end

  protected

  def http_basic_auth
    if params[:token]
      return @user = User.where(token: params[:token]).first!
    elsif params[:password]
      @user = User.all.find{|user|
        Digest::SHA512.hexdigest(user.pseudo_password) == params[:password]
      }
      return @user if @user
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
