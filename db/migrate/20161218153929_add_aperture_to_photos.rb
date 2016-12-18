class AddApertureToPhotos < ActiveRecord::Migration[5.0]
  def change
    add_column :photos, :aperture, :decimal, precision: 5, scale: 2
    add_index :photos, :aperture
    add_index :photos, :file_size
  end

  def data
    Photo.pluck("id, (regexp_replace(meta_data::text, '\\\\u0000', '', 'g'))::json->'f_number'").each do |id, f|
      unless f.nil?
        Photo.where(id: id).update_all aperture: f
      end
    end
  end
end
