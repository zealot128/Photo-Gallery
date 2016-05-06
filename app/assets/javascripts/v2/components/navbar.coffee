window.Navbar = (el, state) ->
  shares = $(el).data('shares')
  tags = $(el).data('tags')
  vm = new Vue({
    el: el,
    data: {
      state: state
      shares: shares
      tags: tags
    }
    watch: {
      state: {
        deep: true
        handler: ->
          this.shares = this.state.shares
          this.tags = this.state.tags
      }
    }
  })
