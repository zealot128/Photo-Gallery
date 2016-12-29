source 'https://rubygems.org'

### Basic Framework
# gem 'rails', '~> 5.0.0.rc1'
gem 'rails', '~> 5.0.0'
gem 'pg'
gem 'slim-rails'
gem 'migration_data'
gem 'hashie'
gem 'local_time'

### Model
gem 'bcrypt-ruby', require: 'bcrypt'
# TODO https://github.com/mbleigh/acts-as-taggable-on/issues/736
gem 'acts-as-taggable-on' #, github: 'mbleigh/acts-as-taggable-on'

### Utils
gem 'ruby-progressbar'
gem 'parallel', require: false
gem "rails-settings-cached"

### Image analysis / conversion
gem 'carrierwave'
gem 'carrierwave-aws'
gem 'carrierwave-video'
gem 'mini_magick'
gem 'mini_exiftool_vendored'
gem 'mini_exiftool'
gem 'geocoder'
gem 'phashion'
gem 'rqrcode'
gem 'tesseract-ocr', require: false
gem 'chronic'
gem 'simple_form'

### Share page / upload
gem 'rubyzip', '>= 1.0.0'
gem 'zip-zip'
gem 'send_file_with_range'
gem 'rack-raw-upload'
gem 'filelock'
gem 'sys-filesystem'
gem 'whenever'
gem 'pry'

### Frontend
gem 'font-awesome-rails'
gem 'coffee-rails'
gem 'jquery-rails'
gem 'sass-rails' , '>= 4.0.2'
gem 'bootstrap-sass'
gem 'uglifier', '>= 1.0.3'
gem 'bootstrap-will_paginate'
gem 'select2-rails'

source 'https://rails-assets.org' do
  gem 'rails-assets-dropzone'
  gem 'rails-assets-moment'
  gem 'rails-assets-lightgallery'
  gem 'rails-assets-videojs-resolution-switcher'
  gem 'rails-assets-video.js'
end

group :development do
  gem 'habtm_generator'
  gem 'listen'
  gem 'annotate'
  gem 'i18n-tasks', '~> 0.9.8'
end

group :test do
  gem 'rspec-rails', '~> 3.5'
end

group :development, :test do
  gem 'puma'
  gem 'pry-rails'
  # gem 'vcr'
  # gem 'webmock'
end

group :production do
  gem 'exception_notification'
  gem 'lograge'
end
