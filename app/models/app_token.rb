# == Schema Information
#
# Table name: app_tokens
#
#  id         :integer          not null, primary key
#  user_id    :integer
#  token      :string
#  user_agent :datetime
#  last_used  :datetime
#  created_at :datetime         not null
#  updated_at :datetime         not null
#

class AppToken < ApplicationRecord
  has_secure_token
  belongs_to :user
end
