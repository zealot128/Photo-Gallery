class AddDurationToPhotos < ActiveRecord::Migration[5.0]
  def change
    change_table :photos do |t|
      t.integer :duration
    end
  end

  def data
    Video.find_each do |v|
      v.save validate: false
    end
  end
end
