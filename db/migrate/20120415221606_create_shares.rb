class CreateShares < ActiveRecord::Migration
  def change
    create_table :shares do |t|
      t.string :name
      t.string :type
      t.string :token

      t.timestamps
    end
    add_index :shares, :type
    add_index :shares, :token, unique: true
  end
end
