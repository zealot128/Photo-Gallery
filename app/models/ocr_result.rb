# == Schema Information
#
# Table name: ocr_results
#
#  id           :integer          not null, primary key
#  base_file_id :integer
#  text         :text
#  created_at   :datetime         not null
#  updated_at   :datetime         not null
#

class OcrResult < ApplicationRecord
  belongs_to :base_file
end
