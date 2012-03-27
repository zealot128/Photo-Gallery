class Photo < ActiveRecord::Base
  has_attached_file :file, styles: {
    thumb: "150x150>",
    medium: "500x500>",
    large: "1000x1000>"

  }
  belongs_to :user
end
