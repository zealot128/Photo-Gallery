class AddMd5ToPhotos < ActiveRecord::Migration
  def change
    add_column :photos, :md5, :string

  end
end
