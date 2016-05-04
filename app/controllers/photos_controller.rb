class PhotosController < ApplicationController
  before_filter :login_required

  def index
    @years = BaseFile.uniq.group(:year).count.sort_by{|a,b|-a}
    @recent = BaseFile.order("created_at desc").limit(20)
    @last_upload = @recent.first.created_at rescue false
    if current_user.token.nil?
      current_user.set_token
      current_user.save validate: false
    end
  end

  def download
    binding.pry
    file = BaseFile.where(id: params[:id], file: params[:filename]).first!
    redirect_to file.file.url
  end

  def destroy
    @photo = BaseFile.find(params[:id])
    d = @photo.day
    @photo.destroy
    d.update_me
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

    path = BaseFile.find_by_share_hash!(params[:hash]).file.path(:large)
    #render :text => open(path, "rb").read
    self.response_body = open(path, "rb")
  end

  def upload
    photo = BaseFile.create_from_upload(params[:file], current_user)
    render json: photo.attributes.except('exif_info').merge(
      valid: photo.valid?,
      errors: photo.errors,
      success: photo.valid?
    )
  end

  def edit
    @photo = BaseFile.find(params[:id])
    render layout: !request.xhr?
  end

  def update
    @photo = BaseFile.find(params[:id])
    @photo.share_ids = params[:photo][:share_ids] if params[:photo][:share_ids]
    @photo.update_attributes!(params[:photo])
    if request.xhr?
      render json: { status: "OK", photo: @photo.as_json}
    else
      redirect_to photos_path
    end
  end

  def rotate
    @photo = BaseFile.find(params[:id])
    @photo.rotate! params[:direction]
    @photo.save
  end

  def ocr
    @photo = BaseFile.find(params[:id])
    @photo.ocr
  end

  def ajax_photos
    @photos = Day.find(params[:id]).photos.order('shot_at asc')

    render @photos, layout: false
  end
end
