class BaseFileUploader < CarrierWave::Uploader::Base
  attr_writer :process_now
  def process_now?(img = nil)
    (!!@process_now) || model.video_processed?
  end

  storage Setting['storage.original'].to_sym

  def store_dir
    store_dir_version('original')
  end

  def store_dir_version(version)
    date = model.shot_at_without_timezone
    if Rails.env.test?
      "test/photos/#{version}/#{date.year}/#{date}"
    else
      "photos/#{version}/#{date.year}/#{date}"
    end
  end
end
