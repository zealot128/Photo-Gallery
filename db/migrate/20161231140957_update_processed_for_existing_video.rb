class UpdateProcessedForExistingVideo < ActiveRecord::Migration[5.0]
  def change
  end

  def data
    Video.update_all video_processed: true
  end
end
