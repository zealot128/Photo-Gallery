class ChangeCoordinatesToFloat < ActiveRecord::Migration[4.2]
  def up
    change_column :photos, :lat, :float
    change_column :photos, :lng, :float
  end

  def down
  end
end
