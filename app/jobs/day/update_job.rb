class Day::UpdateJob < ApplicationJob
  queue_as :default

  def perform(day)
    day.update_me
  rescue Shrine::FileNotFound
  end
end
