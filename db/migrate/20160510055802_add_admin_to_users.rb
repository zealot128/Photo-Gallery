class AddAdminToUsers < ActiveRecord::Migration
  def change
    add_column :users, :admin, :boolean
  end

  def data
    User.order('id').first.update_attribute :admin, true
  end
end
