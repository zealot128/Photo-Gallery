class PhotosController < ApplicationController

  before_filter :http_basic_auth, only: :create
  before_filter :authenticate_user!

  def index
    @groups = current_user.photos.all.group_by{|i|i.shot_at}.sort_by{|a,b| -a.to_i}
  end

  def destroy
    @photo = current_user.photos.find(params[:id])
    @photo.destroy
    redirect_to photos_path
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
      User.find_for_authentication(username, password).present?
    end

  end

end
