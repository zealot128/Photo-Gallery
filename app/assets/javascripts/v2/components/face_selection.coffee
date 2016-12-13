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
    mounted: ->
      that = this
      Vue.nextTick =>
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
      allSimilar: [],
      similarity: 80,
      people: [],
      confidence: 0,
      similarUnassigned: [],
      max: 500,
      person_name: ""
    }
    mounted: ->
      this.selectedFaces = []
      this.selectedFaces.push(this.face.id)
      this.person_name = this.face.person_name
      this.refreshSimilarities()
      # if !this.state.people
      #   Api.getPeople (d)->
      #     this.state.people = d

    methods: {
      refreshSimilarities: (event)->
        event.preventDefault() if event
        Api.getSimilarImages(this.face, this.max, this.similarity, (d) =>
          this.allSimilar = d
          this.similarUnassigned = []
          this.selectedFaces = [ this.face.id ]
          people = {}
          this.allSimilar.forEach (el) =>
            if el.confidence >= this.confidence
              if !el.person_id
                this.similarUnassigned.push(el)
                this.selectedFaces.push(el.id)
              else
                people[el.person_name] ||= 0
                people[el.person_name] += 1

          this.people = []
          for k,v of people
            this.people.push({name: k, count: v})
        )

      setPerson: (event, person) ->
        event.preventDefault()
        this.person_name = person.name
      round: (value) ->
        Math.round(value * 10) / 10

      selectAll: (event)->
        event.preventDefault()
        ids = this.similar.map (i) -> i.id
        this.selectedFaces = ids
        this.selectedFaces.push(this.face.id)

      unselectAll: (event)->
        event.preventDefault()
        this.selectedFaces = [ this.face.id ]


      createPerson: (event)->
        event.preventDefault()
        Api.createPerson(this.person_name, this.selectedFaces, [], =>
          this.face.person_name = this.person_name
          this.refreshSimilarities()
        )
      selected: (face)-> this.selectedFaces.indexOf(face.id) != -1
      toggleSelect: (face)->
        this.toggleObject(face, this.selectedFaces)

      toggleObject: (object, array)->
        if array.indexOf(object.id) != -1
          index = this.array.indexOf(object.id)
          this.array.splice(index, 1)
        else
          array.push(object.id)

    }
    template: '#tpl-face-selection'
  })

