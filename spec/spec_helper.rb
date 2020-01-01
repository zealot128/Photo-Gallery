ENV["RAILS_ENV"] ||= 'test'

require 'pludoni_rspec'
PludoniRspec.run

RSpec.configure do |config|
  config.include ActiveJob::TestHelper
  config.around(:each) do |ex|
    perform_enqueued_jobs do
      ex.run
    end
  end

  config.before(:all) do
    FileUtils.rm_rf('public/photos/test')
  end

  config.before(:each) do
    Setting['rekognition.enabled'] = false
  end
end
