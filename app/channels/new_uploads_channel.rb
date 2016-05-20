# Be sure to restart your server when you modify this file. Action Cable runs in a loop that does not support auto reloading.
class NewUploadsChannel < ApplicationCable::Channel
  def subscribed
    stream_from "uploads_#{current_user.id}"
  end

  # def unsubscribed
  #   # Any cleanup needed when channel is unsubscribed
  # end
  def self.send_new_file(user_id:, file:)
    ActionCable.server.broadcast "uploads_#{user_id}", { file: file.as_json() }
  end
end
