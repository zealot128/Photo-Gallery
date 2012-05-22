class MigrateDates < ActiveRecord::Migration
  def up
    Photo.find_each do |photo|
      photo.year = photo.shot_at.year
      photo.month = photo.shot_at.month
      photo.save
    end
  end

  def down
  end
end
