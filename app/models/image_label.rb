class ImageLabel < ActiveRecord::Base
  has_and_belongs_to_many :base_files
end
