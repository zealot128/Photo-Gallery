class SwitchToCarrierwave < ActiveRecord::Migration[4.2]
  def change
    add_column :photos, :file, :string
    remove_column :photos, "file_file_name"
    remove_column :photos, "file_content_type"
    remove_column :photos, "file_file_size"
    remove_column :photos, "file_updated_at"
  end
end
