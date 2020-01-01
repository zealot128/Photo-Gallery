# == Schema Information
#
# Table name: image_labels
#
#  id         :integer          not null, primary key
#  name       :string
#  created_at :datetime         not null
#  updated_at :datetime         not null
#  name_de    :string
#

class ImageLabel < ActiveRecord::Base
  has_and_belongs_to_many :base_files, join_table: 'base_files_image_labels'

end
