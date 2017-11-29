class SwitchDayToCarrierwave < ActiveRecord::Migration[4.2]
  def change

    add_column :days, :montage, :string
    remove_column :days, "montage_file_name"
    remove_column :days, "montage_content_type"
    remove_column :days, "montage_file_size"
    remove_column :days, "montage_updated_at"
  end
end
