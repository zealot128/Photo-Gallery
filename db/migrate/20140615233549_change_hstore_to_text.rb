class ChangeHstoreToText < ActiveRecord::Migration
  def change
    remove_column :photos, :meta_data
    add_column :photos, :meta_data, :text
  end
end
