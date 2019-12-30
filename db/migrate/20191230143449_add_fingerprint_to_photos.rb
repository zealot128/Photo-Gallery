class AddFingerprintToPhotos < ActiveRecord::Migration[5.1]
  def change
    add_column :photos, :fingerprint, :string
    add_index :photos, :fingerprint
  end
end
