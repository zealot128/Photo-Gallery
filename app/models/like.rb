class Like < ApplicationRecord
  belongs_to :user
  belongs_to :base_file
end
