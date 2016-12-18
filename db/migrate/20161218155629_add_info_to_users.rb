class AddInfoToUsers < ActiveRecord::Migration[5.0]
  def change
    change_table :users do |t|
      t.string :timezone
      t.string :locale
    end
  end
end
