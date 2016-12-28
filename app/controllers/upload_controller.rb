class UploadController < ApplicationController
  skip_before_action :verify_authenticity_token
  before_action :http_basic_auth
  layout false

  def create
    FileUtils.mkdir_p('tmp')
    Filelock "tmp/upload-#{@user.id}.lock", timeout: 600 do
      file = params[:userfile] || params[:upfile] || params[:file]
      exception = nil
      begin
        @photo = BaseFile.create_from_upload(file, @user)
        @user.enable_ip_based_login request
      rescue StandardError => e
        exception = e
        ExceptionNotifier.notify_exception(exception, env: request.env) if defined?(ExceptionNotifier)
        render status: 500, text: "Server Error", layout: false
        return
      end
      UploadLog.handle_file(@photo, file, self, exception)
      if @photo.new_record?
        render plain: "ALREADY_UPLOADED: #{@photo.errors.full_messages}", status: 409, layout: false
      else
        render plain: 'OK', layout: false
      end
    end
  end

  def test
    render plain: ''
  end

  def exists
    if !params[:md5]
      render json: { error: 'No md5 given' }, status: 400
      return
    end
    exists = BaseFile.where(md5: params[:md5]).first
    if exists
      render json: { photo: exists }
    else
      render json: { error: 'no photo found' }, status: 404
    end
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
