class Scroller
  constructor: (@url,@target,@currentPage)->
  checkScroll: ->
    target = @target
    el = @
    if @nearBottomOfPage()
      @currentPage++
      $.ajax
        url: "#{@url}?page=#{@currentPage}"
        complete: (resp) ->
        success: (resp) ->
          if resp.html.length > 5
            target.append resp.html
            el.tick()
          else
            $('.pagination').slideToggle()
    else
      @tick()
  tick: ->
    el = @
    setTimeout ->
      el.checkScroll()
    , 250

  nearBottomOfPage: ->
    @scrollDistanceFromBottom() < 150
  scrollDistanceFromBottom:  (argument) ->
    @pageHeight() - (window.pageYOffset + self.innerHeight)
  pageHeight: ->
    Math.max(document.body.scrollHeight, document.body.offsetHeight)

$ ->
  $('#images').each ->
    el = $(@)
    scroller = new Scroller(el.data("url"), el, el.data("start"))
    scroller.checkScroll()


