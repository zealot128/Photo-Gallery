class Search
  include ActiveModel::Model
  attr_accessor :q, :position

  def search
    if q.blank?
      @q='*'
    end
    options =  {
      execute: false,
      facets: [:make, :model, :exposure_time, :f_number, :iso_speed_ratings, :aperture_value, :flash, :white_balance, :orientation, :software],
      where: {}
    }
    if position.present?
      if result = Geocoder.search(position).first
        options[:where].merge! location: {near: [result.latitude,result.longitude], within: "50km"}
      end
    end
    r = Photo.search q, options
    if q != '*'
      r.body[:query][:dis_max][:queries] << { query_string: {:fields=>["_all"], :query=>q }}
    end
    r.execute
  end
end
