class ImageLabel < ActiveRecord::Base
  has_and_belongs_to_many :base_files, join_table: 'base_files_image_labels'

end
