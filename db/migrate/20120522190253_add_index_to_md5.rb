class AddIndexToMd5 < ActiveRecord::Migration
  def change
    add_index :photos, :md5, :unique => true
  end
end
