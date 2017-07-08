# == Schema Information
#
# Table name: upload_logs
#
#  id           :integer          not null, primary key
#  file_name    :string
#  file_size    :integer
#  status       :integer          default("success")
#  user_id      :integer
#  message      :text
#  ip           :string
#  user_agent   :text
#  created_at   :datetime         not null
#  updated_at   :datetime         not null
#  base_file_id :integer
#

class UploadLog < ActiveRecord::Base
  belongs_to :user
  enum status: [:success, :already_uploaded, :error]
  belongs_to :base_file

  def self.handle_file(file_model, uploaded_file, controller, exception)
    log = new(
      file_size:  File.size(uploaded_file.path),
      file_name:  uploaded_file.try(:original_filename) || File.basename(uploaded_file.path),
      ip:         controller.request.ip,
      user_agent: controller.request.user_agent,
      user:       controller.current_user || controller.instance_variable_get('@user')
    )
    if !file_model || file_model.new_record?
      if file_model && file_model.errors[:md5]
        log.status = 'already_uploaded'
      else
        log.status = 'error'
        if exception
          log.message = exception.inspect
        end
      end
    else
      log.base_file = file_model
      log.status = 'success'
    end
    log.save!
    log
  end
end
