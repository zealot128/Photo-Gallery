# == Schema Information
#
# Table name: geohashes
#
#  id         :integer          not null, primary key
#  lat        :float
#  lng        :float
#  created_at :datetime         not null
#  updated_at :datetime         not null
#

class Geohash < ApplicationRecord
end
