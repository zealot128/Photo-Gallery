class RenameCarrierwaveFile < ActiveRecord::Migration[5.1]
  def change
    rename_column :photos, :file, :old_file
  end
end
