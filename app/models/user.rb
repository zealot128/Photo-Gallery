class User < ActiveRecord::Base
  devise :database_authenticatable, :recoverable, :rememberable, :registerable,
    :authentication_keys => [:username]

  attr_accessible :email, :password, :password_confirmation,
    :remember_me, :username

  has_many :photos
  def self.authenticate(username, password)
    user = User.find_for_authentication(:username => username)
    user.valid_password?(password) ? user : nil
  end
end
