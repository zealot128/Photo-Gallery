class AddDayIdToPhoto < ActiveRecord::Migration
  def change
    add_column :photos, :day_id, :integer
    add_index :photos, :day_id
  end
end
