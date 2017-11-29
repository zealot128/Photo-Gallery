class CreateYears < ActiveRecord::Migration[4.2]
  def change
    change_table :days do |t|
      t.remove :year
      t.integer :year_id, index: true
    end
    create_table :years do |t|
      t.string :name

      t.timestamps null: false
    end
  end

end
