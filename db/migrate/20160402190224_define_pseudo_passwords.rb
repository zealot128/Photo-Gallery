require 'generate_pseudo_password'
class DefinePseudoPasswords < ActiveRecord::Migration[4.2]
  class User < ActiveRecord::Base
  end
  def change
    User.find_each do |u|
      u.pseudo_password = generate_pseudo_password
      u.save
    end
  end
end
