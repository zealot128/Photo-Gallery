class AddMonthStringToMonths < ActiveRecord::Migration
  def change
    add_column :months, :month_string, :string
  end

  def data
    Month.find_each(&:save)
  end
end
