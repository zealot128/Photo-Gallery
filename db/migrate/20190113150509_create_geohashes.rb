class CreateGeohashes < ActiveRecord::Migration[5.1]
  def change
    create_table :geohashes do |t|
      t.float :lat
      t.float :lng

      t.timestamps
    end
  end

  def data
    BaseFile.where.not(lat: nil).find_each { |s|
      s.update_geohash
      s.save if s.changed?
    }
  end
end
