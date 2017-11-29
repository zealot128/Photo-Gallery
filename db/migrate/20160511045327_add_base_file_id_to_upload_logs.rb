class AddBaseFileIdToUploadLogs < ActiveRecord::Migration[4.2]
  def change
    add_column :upload_logs, :base_file_id, :integer
  end

  def data
    UploadLog.where(base_file_id: nil).each do |ul|
      bf = BaseFile.where('created_at > ?', 1.week.ago).where(file: ul.file_name).first
      if bf
        ul.update(base_file: bf)
      end
    end
  end
end
