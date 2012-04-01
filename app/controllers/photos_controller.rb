class PhotosController < ApplicationController

  before_filter :http_basic_auth, only: :create
  before_filter :login_required

  def index
    @groups = Photo.all.group_by{|i|i.shot_at}.sort_by{|a,b| -a.to_i}
  end

  def destroy
    @photo = current_user.photos.find(params[:id])
    @photo.destroy
    redirect_to photos_path
  end

  def shared

    response.headers['Content-Type'] = 'image/jpeg'
    response.headers['Content-Disposition'] = 'inline'

    path = Photo.find_by_share_hash!(params[:hash]).path(:large)
    render :text => open(path, "rb").read
  end

  protect_from_forgery except: :create
  def create
    photo = Photo.new
    photo.shot_at = EXIFR::JPEG.new(params[:userfile].path).exif[:date_time].to_date
    photo.user = current_user
    photo.file = params[:userfile]
    photo.save
    render :text => "OK"
  end

  protected
  def http_basic_auth
    return true if current_user

    authenticate_or_request_with_http_basic do |username, password|
      if user = User.authenticate(username, password)
        session[:user_id] = user.id
        true
      else
        false
      end
    end

  end

end
