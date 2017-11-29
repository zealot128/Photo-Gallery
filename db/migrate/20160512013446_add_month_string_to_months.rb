class AddMonthStringToMonths < ActiveRecord::Migration[4.2]
  def change
    add_column :months, :month_string, :string
  end

  def data
    Month.find_each(&:save)
  end
end
