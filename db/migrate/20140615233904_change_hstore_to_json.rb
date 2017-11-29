class ChangeHstoreToJson < ActiveRecord::Migration[4.2]
  def change
    remove_column :photos, :meta_data
    add_column :photos, :meta_data, :json
  end
end
