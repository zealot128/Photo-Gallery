class UploadLog < ActiveRecord::Base
  belongs_to :user
  enum status: [ :success, :already_uploaded, :error ]

  def self.handle_file(base_file, uploaded_file, controller, exception)
    log = new(
      file_size:  File.size(uploaded_file.path),
      file_name:  uploaded_file.try(:original_filename) || File.basename(uploaded_file.path),
      ip:         controller.request.ip,
      user_agent: controller.request.user_agent,
      user:       controller.current_user || controller.instance_variable_get('@user')
    )
    if uploaded_file.new_record?
      if uploaded_file.errors[:md5]
        log.status = 'already_uploaded'
      else
        log.status = 'error'
        if exception
          log.message = exception.inspect
        end
      end
    else
      log.status = 'success'
    end
    log.save!
    log
  end
end
