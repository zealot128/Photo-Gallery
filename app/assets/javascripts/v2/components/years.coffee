window.Years = (domEl, state) ->
  el = $(domEl)
  g = new Vue({
    el: el[0],
    data: {
      years: el.data('years')
      openYears: []
    }
    template: '#tpl-years'
    methods: {
      toggleYear: (year, event) ->
        event.preventDefault()
        if this.openYears.indexOf(year.id) != -1
          index = this.openYears.indexOf(year.id)
          this.openYears.splice(index, 1)
        else
          this.openYears.push(year.id)
      isOpen: (year) ->
        this.openYears.indexOf(year.id) != -1
    }
  })

Vue.component('vue-year', {
  props: [ 'year' ],
  data: ->
    months: []
  template: '#tpl-year'
  created: ->
    Api.year(this.year.name, (e) =>
      this.months = e.months
    )


})
