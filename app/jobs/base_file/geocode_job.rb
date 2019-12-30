class BaseFile::GeocodeJob < ApplicationJob
  queue_as :default

  def perform(base_file)
    base_file.update_gps(save: false)
    if base_file.lat? and base_file.lng?
      floor_lon = ((lng + 180) * 10).to_i
      floor_lat = ((lat + 90) * 10).to_i
      self.geohash = (floor_lon * 0x1000) | floor_lat
      Geohash.where(id: geohash).first_or_create(lat: lat, lng: lng)
    end
    base_file.save
  end
end
