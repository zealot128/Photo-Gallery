jQuery ->
  window.loader = $('#loader')

  $('.dropdown-toggle').dropdown()

  setTimeout ->
    if $('.dropzone').length > 0
      dropzone = $('.dropzone')[0].dropzone
      dropzone.on 'success', (file,json)->
        if !json.valid
          messages = (attribute + ' ' + message for attribute,message of json.errors)
          this.defaultOptions.error(file, messages.join(', '))
  , 200


