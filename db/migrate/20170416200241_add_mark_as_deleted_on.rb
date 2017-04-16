class AddMarkAsDeletedOn < ActiveRecord::Migration[5.0]
  def change
    add_column :photos, :mark_as_deleted_on, :datetime, default: nil
  end
end
