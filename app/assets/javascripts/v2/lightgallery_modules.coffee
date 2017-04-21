defaults = {
}
Delete = (element) ->
  this.core = $(element).data('lightGallery')
  this.$el = $(element)
  this.core.s = $.extend({}, defaults, this.core.s)
  this.init()
  return this
Delete.prototype.init = ->
  html = '<span class="lg-icon lg-delete"><i class="fa fa-fw fa-trash-o"></i></span>'
  this.core.$outer.find('.lg-toolbar').append(html)
  this.core.$outer.find('.lg-delete').on('click.lg', =>
    if confirm("Really delete this item?")
      this.core.$el.trigger('deleteImage.lg', this.core)
        # this.core.$el.find('.lg-thumb-item').get(this.core.index).remove()
        # this.core.$el.find('.lg-item').get(this.core.index).remove()
  )
Delete.prototype.destroy = ->
  true


Edit = (element) ->
  this.core = $(element).data('lightGallery')
  this.$el = $(element)
  this.core.s = $.extend({}, defaults, this.core.s)
  this.init()
  return this
Edit.prototype.init = ->
  html = '<span class="lg-icon lg-edit"><i class="fa fa-fw fa-pencil-square-o"></i></span>'
  this.core.$outer.find('.lg-toolbar').append(html)
  this.core.$outer.find('.lg-edit').on('click.lg', =>
    this.core.$el.trigger('editImage.lg', this.core)
        # this.core.$el.find('.lg-thumb-item').get(this.core.index).remove()
        # this.core.$el.find('.lg-item').get(this.core.index).remove()
  )

Edit.prototype.destroy = ->
  true

if currentUser
  $.fn.lightGallery.modules.edit = Edit
  $.fn.lightGallery.modules.delete = Delete
