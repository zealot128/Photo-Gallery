class DavController < UploadController

  def create
    filename = params[:filename].split('/').last
    if request.body.respond_to?(:path)
      tf = request.body
    else
      tf = Tempfile.new(['webdavupload', File.extname(filename)])
      tf.binmode
      tf.write(request.body.read)
      tf.flush
    end
    file = ActionDispatch::Http::UploadedFile.new(tempfile: tf, filename: filename )

    begin
      @photo = BaseFile.create_from_upload(file, @user)
    rescue StandardError => e
      exception = e
      ExceptionNotifier.notify_exception(exception, env: request.env) if defined?(ExceptionNotifier)
      render status: 500, text: "Server Error (#{e.inspect})\n\n#{e.backtrace.inspect}", layout: false
      return
    end
    UploadLog.handle_file(@photo, file, self, exception)
    if !@photo.new_record? || (@photo.errors[:md5].present?)
      render plain: 'OK', layout: false
    else
      render plain: "ALREADY_UPLOADED: #{@photo.errors.full_messages}", status: 409, layout: false
    end
  end

  def index
  end
end
