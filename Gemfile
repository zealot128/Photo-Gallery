source 'https://rubygems.org'

gem 'rails', '~> 5.2.0'
gem 'pg'
gem 'slim-rails'
gem 'migration_data'
gem 'hashie'
gem 'local_time'

### Model
gem 'bcrypt-ruby', require: 'bcrypt'
gem 'acts-as-taggable-on'

### Utils
gem 'ruby-progressbar'
gem 'parallel', require: false
gem "rails-settings-cached", '~> 0.6'
gem 'request_store'

### Image analysis / conversion
gem 'carrierwave'
gem 'carrierwave-vips'
gem 'aws-sdk-s3'
gem 'aws-sdk-rekognition'
gem "shrine", "~> 3.0"
gem "image_processing", "~> 1.8"
gem 'marcel'
gem 'streamio-ffmpeg'

gem 'carrierwave-video', git: 'https://github.com/zealot128-os/carrierwave-video.git'
gem 'mini_magick'
# TODO: PR
gem 'mini_exiftool_vendored', git: 'https://github.com/zealot128-os/mini_exiftool_vendored.git'
gem 'mini_exiftool'
gem 'geocoder'
gem "dhash-vips"
gem 'rqrcode'
gem 'tesseract-ocr', require: false
gem 'chronic'
gem 'simple_form'
gem 'bootsnap', require: false
gem 'groupdate'

### Share page / upload
gem 'rubyzip', '>= 1.0.0'
gem 'zip-zip'
gem 'send_file_with_range', git: 'https://github.com/metalels/send_file_with_range.git', ref: 'rails51'
gem 'rack-raw-upload'
gem 'filelock'
gem 'sys-filesystem'
gem 'whenever'
gem 'pry-rails'

### Frontend
gem 'font-awesome-rails'
gem 'coffee-rails'
gem 'jquery-rails'
gem 'sass-rails', '>= 4.0.2'
gem 'bootstrap-sass'
gem 'uglifier', '>= 1.0.3'
gem 'bootstrap-will_paginate'
gem 'select2-rails'
gem 'webpacker', '~> 5.0'

source 'https://rails-assets.org' do
  gem 'rails-assets-dropzone'
  gem 'rails-assets-moment'
  gem 'rails-assets-lightgallery'
  gem 'rails-assets-videojs-resolution-switcher'
  gem 'rails-assets-video.js'
end

group :development do
  gem 'dotenv-rails'
  gem 'pludoni_rspec', git: 'https://github.com/pludoni/pludoni_rspec.git'
  gem 'rubocop', require: false
  gem 'rubocop-performance', require: false
  gem 'rubocop-rails', require: false
  gem 'solargraph', require: false
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
  # gem 'vcr'
  # gem 'webmock'
end

gem "sentry-raven"
gem 'silencer'

gem "good_job", "~> 1.0"
# gem "good_job", path: '../good_job'
