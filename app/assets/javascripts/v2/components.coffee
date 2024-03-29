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

  $('.js-years').each ->
    Years(this, state)

  $('.js-face-selection').each ->
    FaceSelection(this, state)

  $('.js-face-image').each ->
    FaceImage(this, state)

  $('.js-unassigned-filter').each ->
    UnassignedFacesManager(this, state)
