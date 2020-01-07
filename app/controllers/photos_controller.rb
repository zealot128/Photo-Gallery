class PhotosController < ApplicationController
  before_action :login_required

  def download
    file = BaseFile.find(params[:id])
    redirect_to file.file.url
  end

  def destroy
    @photo = BaseFile.find(params[:id])
    @photo.mark_as_delete!
    respond_to do |f|
      f.html {
        redirect_to photos_path
      }
      f.json {
        render json: { status: 'success' }
      }
    end
  end

  def undelete
    @photo = BaseFile.find(params[:id])
    @photo.update_column :mark_as_deleted_on, nil
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

    path = BaseFile.find_by!(share_hash: params[:hash]).file.path(:large)
    self.response_body = File.open(path, "rb").read
  end

  def upload
    photo = nil
    exception = nil
    begin
      photo = BaseFile.create_from_upload(params[:file], current_user)
    rescue StandardError => e
      ExceptionNotifier.notify_exception(e, env: request.env) if defined?(ExceptionNotifier)
      exception = e
    end
    if exception
      Rails.logger.error "ERROR WHILE UPLOAD: #{e.inspect}"
    end
    UploadLog.handle_file(photo, params[:file], self, exception)
    if photo
      render json: photo.attributes.except('exif_info').merge(
        valid: photo.valid?,
        errors: photo.errors,
        success: photo.valid?
      ), status: photo.valid? ? 201 : 422
    else
      render json: {
        valid: false,
        errors: [exception.inspect],
        success: false
      }, status: :unprocessable_entity
    end
  end

  def edit
    @photo = BaseFile.find(params[:id])
    render layout: !request.xhr?
  end

  def update
    @photo = BaseFile.find(params[:id])
    @photo.share_ids = params[:photo][:share_ids] || []
    new_share = params[:photo].delete(:new_share)
    binding.pry
    @photo.update!(params[:photo])
    if new_share.present?
      share = Share.where(name: new_share).first_or_create(user: current_user)
      @photo.shares << share unless @photo.shares.include?(share)
    end
    if request.xhr? || request.format.json?
      render json: { status: "OK", photo: @photo.as_json }
    else
      redirect_to photos_path
    end
  end

  def rotate
    @photo = BaseFile.find(params[:id])
    @photo.rotate!(params[:direction])
    @photo.save
    render json: { file: @photo.as_json }
  end

  def ocr
    @photo = BaseFile.find(params[:id])
    @photo.ocr
  end

  def like
    @photo = BaseFile.find(params[:id])
    @photo.liked_by << current_user unless @photo.liked_by.include?(current_user)
    render json: { file: @photo.as_json }
  end

  def unlike
    @photo = BaseFile.find(params[:id])
    @photo.liked_by -= [current_user] if @photo.liked_by.include?(current_user)
    render json: { file: @photo.as_json }
  end
end
