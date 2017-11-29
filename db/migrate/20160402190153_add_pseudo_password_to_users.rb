class AddPseudoPasswordToUsers < ActiveRecord::Migration[4.2]
  def change
    add_column :users, :pseudo_password, :string
  end
end
