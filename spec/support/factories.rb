def valid_user
  User.create! username: "test", password: "test123", email: "info@test.com", password_confirmation: "test123"
end
