source 'https://rubygems.org'

gem 'rails', '~>3.2.2'

gem "bcrypt-ruby", :require => "bcrypt"
gem 'exifr'
gem "geocoder"
gem "haml-rails"
gem 'paperclip', '~> 2.3'
gem "rack-raw-upload"
gem "ruby-progressbar", :require => "progressbar"
gem "simple_form"
gem 'sqlite3'
gem "thin"
gem 'yaml_db'


group :production do
  gem 'mysql2', '~> 0.3.7'
end
group :development, :test do
  gem "pry"
  gem 'rb-inotify', '~> 0.8.8'
end
group :development do
  gem "nifty-generators"
  gem 'capistrano'
  gem 'capistrano_colors'
  gem "rvm-capistrano"
end

group :test do
  gem "rspec-rails"
  gem "guard-rspec"
  gem "mocha"
end


group :assets do
  gem 'coffee-rails', '~> 3.2.1'
  gem 'fancybox-rails', :git => 'https://github.com/sverigemeny/fancybox-rails'
  gem 'jquery-rails'
  gem 'sass-rails',   '~> 3.2.3'
  gem "twitter-bootstrap-rails"
  gem 'uglifier', '>= 1.0.3'
  gem "less-rails"
end


