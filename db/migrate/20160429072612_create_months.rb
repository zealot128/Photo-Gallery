class CreateMonths < ActiveRecord::Migration
  def change
    create_table :months do |t|
      t.integer :month_number
      t.integer :year_id

      t.timestamps null: false
    end
    add_index :months, :year_id
    change_table :days do |t|
      t.remove :year_id
      t.integer :month_id
    end
    add_index :days, :month_id
  end

  def data
    Day.find_each do |day|
      day.save
    end
  end
end
