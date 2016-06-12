class PhotosController < ApplicationController
  before_action :login_required

  def download
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
      f.json {
        render json: { status: 'success' }
      }
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
    photo = nil
    exception = nil
    begin
      photo = BaseFile.create_from_upload(params[:file], current_user)
    rescue StandardError => e
      exception = e
    end
    UploadLog.handle_file(photo, params[:file], self, exception)
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
    @photo.share_ids = params[:photo][:share_ids] || []
    new_share = params[:photo].delete(:new_share)
    @photo.update_attributes!(params[:photo])
    if new_share.present?
      share = Share.where(name: new_share).first_or_create(user: current_user)
      @photo.shares << share unless @photo.shares.include?(share)
    end
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
    render json: { file: @photo.as_json }
  end

  def ocr
    @photo = BaseFile.find(params[:id])
    @photo.ocr
  end
end
