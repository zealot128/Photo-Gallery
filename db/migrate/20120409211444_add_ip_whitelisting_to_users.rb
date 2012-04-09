class AddIpWhitelistingToUsers < ActiveRecord::Migration
  def change
    change_table :users do |t|
      t.string :last_ip
      t.datetime :last_upload
      t.boolean :allowed_ip_storing
    end
  end
end
