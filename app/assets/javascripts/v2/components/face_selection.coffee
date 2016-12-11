window.FaceImage = (domEl, state) ->
  el = $(domEl)
  g = new Vue({
    el: el[0],
    template: '#tpl-face-image'
    data: {
      photo: el.data('photo'),
      image_height: 0,
      image_width: 0,
    }
    ready: ->
      that = this
      $(this.$el).find('img').on 'load', ->
        that.image_width = this.width
        that.image_height = this.height
  })

Vue.component('bounding-box', {
  props: [ 'face', 'width', 'height' ]
  template: '#tpl-bounding-box'
  computed: {
    name: -> this.face.person_name
    styleObject: ()->
      bb = this.face.bounding_box
      w = Math.round bb.width * this.width
      h = Math.round bb.height * this.height
      t = Math.round bb.top * this.height
      l = Math.round bb.left * this.width
      {
        left: l + "px"
        top: t + "px",
        width: w + "px",
        height: h + "px"
      }
  }
})

window.FaceSelection = (domEl, state) ->
  el = $(domEl)

  g = new Vue({
    el: el[0],
    data: {
      state: state,
      face: el.data('face'),
      selectedFaces: [],
      unselectedFaces: [],
      similar: el.data('similar'),
      person_name: ""
    }
    ready: ->
      this.selectedFaces = []
      this.similar.forEach (el) =>
        if el.person_id == this.face.person_id || !el.person_id
          this.selectedFaces.push(el.id)
        else
          this.unselectedFaces.push(el.id)
      this.selectedFaces.push(this.face.id)
      this.person_name = this.face.person_name
    methods: {
      createPerson: (event)->
        event.preventDefault()
        Api.createPerson(this.person_name, this.selectedFaces, this.unselectedFaces, => this.face.person_name = this.person_name)
      selected: (face)-> this.selectedFaces.indexOf(face.id) != -1
      toggleSelect: (face)->
        this.toggleObject(face, this.selectedFaces)
        this.toggleObject(face, this.unselectedFaces)

      toggleObject: (object, array)->
        if array.indexOf(object.id) != -1
          array.$remove(object.id)
        else
          array.push(object.id)

    }
    template: '#tpl-face-selection'
  })

