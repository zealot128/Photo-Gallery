class AddLocationsToDays < ActiveRecord::Migration
  def change
    add_column :days, :locations, :string
  end
end
