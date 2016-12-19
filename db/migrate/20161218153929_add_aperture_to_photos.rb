class AddApertureToPhotos < ActiveRecord::Migration[5.0]
  def change
    add_column :photos, :aperture, :decimal, precision: 5, scale: 2
    add_index :photos, :aperture
    add_index :photos, :file_size
  end

  def data
    Photo.pluck("id, (regexp_replace(meta_data::text, '\\\\u0000', '', 'g'))::json->'f_number'").each do |id, f|
      unless f.nil?
        new_val = case f
                  when %r{(\d+)/(\d+)} then Rational($1.to_i, $2.to_i).to_f
                  else f.to_f
                  end
        Photo.where(id: id).update_all aperture: new_val
      end
    end
  end
end
