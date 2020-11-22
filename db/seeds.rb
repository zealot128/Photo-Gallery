
require "readline"

password = ENV['INITIAL_ADMIN_PASSWORD'].presence

unless password
  puts "Input password for user 'share': (password will be displayed)"
  password = Readline.readline("> ", true).strip
end

User.create! email: "admin@example.com", password: buf, password_confirmation: buf, username: "admin", admin: true
Share.create! name: "Public"
