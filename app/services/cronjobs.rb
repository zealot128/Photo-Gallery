module Cronjobs
  KEEP_LOG = 30.days
  ALLOWED_OCR_TAGS = ["Text", "Page", "Label", "Brochure", "Flyer", "Paper", "Poster", "File", "Webpage", "Screen", "Letter", "Paper"]

  def self.run
    lock_file = Rails.root.join('tmp', 'cron.lock')
    Filelock lock_file, wait: 1.minute, timeout: 15.minutes do
      # S3Import.run
      process_videos(limit: 2)
      LoggingEntry.where('created_at < ?', KEEP_LOG.ago).delete_all
    end
  end
end
