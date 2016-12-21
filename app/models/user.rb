# == Schema Information
#
# Table name: users
#
#  id                 :integer          not null, primary key
#  username           :string
#  email              :string
#  password_hash      :string
#  password_salt      :string
#  created_at         :datetime         not null
#  updated_at         :datetime         not null
#  last_ip            :string
#  last_upload        :datetime
#  allowed_ip_storing :boolean
#  token              :string
#  pseudo_password    :string
#  admin              :boolean
#  timezone           :string
#  locale             :string
#

class User < ActiveRecord::Base
  attr_accessor :password
  before_save :prepare_password

  has_many :base_files
  validates_presence_of :username
  validates_uniqueness_of :username, :email, :allow_blank => true
  validates_format_of :username, :with => /\A[-\w\._@]+\Z/i, :allow_blank => true, :message => "should only contain letters, numbers, or .-_@"
  validates_format_of :email, :with => /\A[-a-z0-9_+\.]+\@([-a-z0-9]+\.)+[a-z0-9]{2,4}\Z/i
  validates_presence_of :password, :on => :create
  validates_confirmation_of :password
  validates_length_of :password, :minimum => 4, :allow_blank => true

  before_create :set_token
  before_save :set_token, if: :password_hash_changed?

  # login can be either username or email address
  def self.authenticate(login, pass)
    user = find_by_username(login) || find_by_email(login)
    return user if user && user.password_hash == user.encrypt_password(pass)
  end

  def self.authenticate_by_ip(request)
    user = find_by_last_ip(request.env["REMOTE_ADDR"])
    user if user and user.last_upload > 15.minutes.ago
  end

  def set_token
    self.token = SecureRandom.hex(16)
  end

  def encrypt_password(pass)
    BCrypt::Engine.hash_secret(pass, password_salt)
  end

  def enable_ip_based_login(request)
    update_attributes :last_ip => request.env["REMOTE_ADDR"],
      :last_upload => Time.now
  end

  private

  def prepare_password
    unless password.blank?
      self.password_salt = BCrypt::Engine.generate_salt
      self.password_hash = encrypt_password(password)
    end
  end
end
