
require "readline"
puts "Input password for user 'share': (password will be displayed)"
buf = Readline.readline("> ", true).strip

User.create! email: "admin@example.com", password: buf, password_confirmation: buf, username: "share", admin: true
Share.create! name: "Public"
