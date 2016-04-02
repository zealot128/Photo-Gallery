class AddPseudoPasswordToUsers < ActiveRecord::Migration
  def change
    add_column :users, :pseudo_password, :string
  end
end
