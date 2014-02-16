$ ->
  $(document).on 'click', '.js-modal, #js-modal .modal-body a', (e)->
    return true if $(this).data('toggle')
    e.preventDefault()
    modal = """
    <div class='modal container' id='js-modal'  role="dialog" >
      <div class='no-modal-dialog'>
        <div class='modal-content'>
          <div class='modal-header'>
            <button type="button" class="close" data-dismiss="modal" aria-hidden="true">&times;</button>
            <h4 class="modal-title"></h4>
          </div>
          <div class='modal-body'></div>
          <div class='modal-footer'></div>
        </div>
      </div>
    </div>
    """

    modal = $(modal)
    self = $(this)
    self.attr('href')
    $.get self.attr('href'), (response)->
      data = $('<div>'+response+'</div>').wrap('<div/>')
      footer_provided = data.find('#modal-footer')
      if footer_provided.length > 0
        modal.find('.modal-footer').html footer_provided.remove().html()
      modal.find('.modal-body').html data
      if $('#js-modal').length == 0
        $('body').append(modal)
        $('#js-modal').modal(show: true, backdrop: false)
      else
        $('#js-modal').html modal.html()
      $('#js-modal').trigger('modal-changed', self.attr('href'))

      if !$('#js-modal').is(':visible')
        $('#js-modal').modal(show: true)

    return false

  $(document).on 'submit', '#js-modal form', (e)->
    e.preventDefault()
    form = $(this)
    $.ajax
      url: form.attr("action")
      type: if form.attr('method') == 'GET' then 'GET' else 'POST'
      data: form.serialize()
      complete: (d,e)->
        window.loader.hide()
        jsonResult = null
        try
          jsonResult = $.parseJSON(d.responseText)
          if jsonResult.status == 'OK' or jsonResult.status == 'success'
            $('#js-modal').modal('hide')
          else
            $('#js-modal').find('.modal-body').html d.jsonResult
            $('#js-modal').trigger('modal-response-error', jsonResult)
        catch e
          $('#js-modal').find('.modal-body').html d.responseText

        $('#js-modal').trigger('modal-changed', form.attr('action'))
    return false
