#= require vue
#= require v2/lightgallery_modules
#= require v2/api
#= require v2/components

$ ->
  $('.js-photo-gallery').each ->
    el = $(this)
    createGallery( el )

