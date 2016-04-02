class AddTypeToPhotos < ActiveRecord::Migration
  def change
    add_column :photos, :type, :string
    add_index :photos, :type
    execute 'update photos set type = \'Photo\''
  end
end
