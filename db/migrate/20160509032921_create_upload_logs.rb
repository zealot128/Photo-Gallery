class CreateUploadLogs < ActiveRecord::Migration
  def change
    create_table :upload_logs do |t|
      t.string :file_name
      t.integer :file_size, limit: 8
      t.integer :status, default: 0
      t.belongs_to :user, index: true, foreign_key: true
      t.text :message
      t.string :ip
      t.text :user_agent

      t.timestamps null: false
    end
  end
end
