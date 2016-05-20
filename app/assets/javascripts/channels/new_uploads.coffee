App.new_uploads = App.cable.subscriptions.create "NewUploadsChannel",
  connected: -> true
    # Called when the subscription is ready for use on the server

  disconnected: -> true
    # Called when the subscription has been terminated by the server

  # Overwritten by Cable
  received: (data) -> true
    # Called when there's incoming data on the websocket for this channel
