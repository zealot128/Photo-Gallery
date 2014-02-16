if Rails.env.development?
  Slim::Engine.set_default_options pretty: true, sort_attrs: false
else
  Slim::Engine.set_default_options pretty: false, sort_attrs: false
end
