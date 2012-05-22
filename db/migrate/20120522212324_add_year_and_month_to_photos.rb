class AddYearAndMonthToPhotos < ActiveRecord::Migration
  def change
    add_column :photos, :year, :integer, :limit => 2
    add_column :photos, :month, :integer, :limit => 2
    add_index :photos, :year
    add_index :photos, :month
  end
end
