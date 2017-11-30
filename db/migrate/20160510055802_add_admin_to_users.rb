class AddAdminToUsers < ActiveRecord::Migration[4.2]
  def change
    add_column :users, :admin, :boolean
  end

  def data
    User.order('id').first.try(:update_attribute, :admin, true)
  end
end
