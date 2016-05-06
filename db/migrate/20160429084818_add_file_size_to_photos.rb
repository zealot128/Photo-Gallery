class AddFileSizeToPhotos < ActiveRecord::Migration
  def change
    add_column :photos, :file_size, :integer, limit: 8
  end

  def data
    BaseFile.find_each do |bf|
      begin
        bf.update_column :file_size, bf.file.size
      rescue StandardError => e
        puts "Error with #{bf.id}"
        puts e.inspect
      end
    end
  end
end
