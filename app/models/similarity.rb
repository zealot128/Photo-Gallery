# == Schema Information
#
# Table name: similarities
#
#  id             :integer          not null, primary key
#  image_face1_id :integer
#  image_face2_id :integer
#  similarity     :float
#  created_at     :integer
#

class Similarity < ApplicationRecord
end
