class AddUserIdToShares < ActiveRecord::Migration[4.2]
  def change
    add_column :shares, :user_id, :integer
    execute 'update shares set user_id = (select id from users order by id limit 1)'
  end
end
