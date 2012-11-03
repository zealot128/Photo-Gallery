class CreateDays < ActiveRecord::Migration
  def change
    create_table :days do |t|
      t.date :date
      t.integer :year

      t.timestamps
    end
    add_index :days, :date
  end
end
