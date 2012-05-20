class PhotosController < ApplicationController

  before_filter :http_basic_auth, only: :create
  before_filter :login_required

  def index
    @groups = Photo.grouped
  end

  def destroy
    @photo = current_user.photos.find(params[:id])
    @photo.destroy
    respond_to do |f|
      f.html {
        redirect_to photos_path
      }
      f.js
    end
  end

  def shared
    response.headers['Content-Type'] = 'image/jpeg'
    response.headers['Content-Disposition'] = 'inline'

    path = Photo.find_by_share_hash!(params[:hash]).file.path(:large)
    #render :text => open(path, "rb").read
    self.response_body = open(path, "rb")
  end

  protect_from_forgery except: :create

  def create
    Photo.create_from_upload(params[:userfile], current_user)
    current_user.enable_ip_based_login request
    render :text => "OK"
  end

  def upload
    photo = Photo.create_from_upload(params[:file], current_user)
    render json: photo.attributes.merge(
      valid: photo.valid?,
      errors: photo.errors,
      success: photo.valid?
    )
  end

  def edit
    @photo = Photo.find(params[:id])
    render layout: !request.xhr?
  end

  def update
    @photo = Photo.find(params[:id])
    @photo.share_ids = params[:photo][:share_ids]
    if request.xhr?
      render json: { status: "OK"}
    else
      redirect_to photos_path
    end
  end

  protected
  def http_basic_auth
    return true if current_user
    if by_ip       = User.authenticate_by_ip(request)
      session[:user_id] = by_ip.id
      return true
    end

    authenticate_or_request_with_http_basic do |username, password|
      if by_username = User.authenticate(username, password)
        session[:user_id] = by_username.id
        true
      else
        false
      end
    end
  end
end
