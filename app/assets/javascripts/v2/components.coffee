#= require_tree ./components

state = {
  shares: null,
  tags: null
  updateAll: ->
    Api.tags (t) => this.tags = t
    Api.shares (t) => this.shares = t
}
window.state = state

$ ->
  $('.js-navbar').each ->
    Navbar(this, state)

  $('.js-photo-gallery').each ->
    Gallery(this, state )



