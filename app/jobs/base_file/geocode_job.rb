class BaseFile::GeocodeJob < ApplicationJob
  queue_as :default

  def perform(base_file)
    base_file.update_gps(save: false)
    if base_file.lat? and base_file.lng?
      floor_lon = ((base_file.lng + 180) * 10).to_i
      floor_lat = ((base_file.lat + 90) * 10).to_i
      base_file.geohash = (floor_lon * 0x1000) | floor_lat
      Geohash.where(id: base_file.geohash).first_or_create(lat: base_file.lat, lng: base_file.lng)
    end
    base_file.save
    base_file.processed_successfully!(:geocoding)
  end
end
