EditMixin = {
  data: ->
    allTags: null
    allShares: null,
    newTag: ""
    newShare: ""
    buttonText: "Save"
    tagIds: null
    shareIds: null
    editMode: false
  watch:
    state:
      handler: ->
        this.allShares = this.state.shares if this.state.shares
        this.allTags = this.state.tags if this.state.tags
      deep: true
  methods:
    tagged: (tag) -> this.tagIds.indexOf(tag.id) != -1
    hasShare: (share) -> this.shareIds.indexOf(share.id) != -1

    toggleObject: (object, array)->
      if array.indexOf(object.id) != -1
        array.$remove(object.id)
      else
        array.push(object.id)
    toggleTag: (tag) -> this.toggleObject(tag, this.tagIds)
    toggleShare: (share) -> this.toggleObject(share, this.shareIds)
    showModal: ->
      this.editMode = true
      this.state.updateAll() if !this.allTags
      Vue.nextTick =>
        this.modalEl().modal('show').css({'zIndex': 10000 })
    modalEl: -> $(this.$el)
    closeModal: ->
      this.editMode = false
      this.modalEl().modal('hide')
}

Vue.component('vue-bulk-edit', {
  mixins: [ EditMixin ],
  props: [ 'files', 'state' ],
  template: '#tpl-bulk-edit',
  data: ->
    chosenFiles: []
  methods: {
    modalEl: -> $(this.$el).find('.modal')
    startEditing: ->
      this.tagIds = []
      this.shareIds = []
      this.showModal()
      this.chosenFiles = this.files.map( (f)-> f.id )

      tags = _.map(this.files, (f) -> f.tag_ids )
      this.tagIds = _.intersection.apply(this, tags)
      shares = _.map(this.files, (f) -> f.share_ids )
      this.shareIds = _.intersection.apply(this, shares)

    isChosen: (file)-> this.chosenFiles.indexOf(file.id) != -1
    toggleFile: (file)-> this.toggleObject(file, this.chosenFiles)
    save: ->
      request = { tag_ids: this.tagIds, new_tag: this.newTag, share_ids: this.shareIds, new_share: this.newShare, file_ids: this.chosenFiles }
      this.buttonText = "...saving"
      Api.bulkUpdate request, (response)=>
        for file in response
          localFile = this.files.filter((f)-> f.id == file.id )[0]
          localFile.share_ids = file.share_ids
          localFile.tags = file.tags

        this.buttonText = "saved!"
        this.state.updateAll()
        this.newTag = ""
        this.newShare = ""
        setTimeout =>
          this.closeModal()
        , 200

  }
})

Vue.component('vue-edit', {
  mixins: [ EditMixin ],
  props: ['file', 'state'],
  template: '#tpl-edit'
  data: ->
    notRotating: true
  ready: ->
    this.state.updateAll() if !this.allTags
    this.modalEl().modal('show').css({'zIndex': 10000 })
    this.tagIds = this.file.tag_ids
    this.shareIds = this.file.share_ids
  computed: {
    isImage: -> this.file.type == "Photo"
  }

  methods: {
    rotate: (direction, event)->
      event.preventDefault()
      this.notRotating = false
      Api.rotate this.file.id, direction, (response) =>
        part = (new Date).getTime()
        debugger
        that = this
        for version, name of this.file.versions
          new_version =  name.replace(/\?\d$/, "") + "?" + part
          this.file.versions[version] = new_version
          $('img').filter(-> this.src.indexOf(name) != -1).each ->
            $(this).attr('src', new_version)
        this.notRotating = true

    save: ->
      hasNewTag = this.newTag? and this.newTag != ""
      filteredTags = this.allTags.filter( (tag)=> this.tagIds.indexOf(tag.id) != -1  ).map((tag) -> tag.name )
      if hasNewTag
        filteredTags.push this.newTag

      request = { tag_list: filteredTags, share_ids: this.shareIds || [], new_share: this.newShare }
      this.buttonText = "...saving"
      Api.saveImage this.file.id, request, (response)=>
        this.file.tag_ids = response.photo.tag_ids
        this.file.share_ids = response.photo.share_ids
        this.tagIds = this.file.tag_ids
        this.shareIds = this.file.share_ids
        this.buttonText = "saved!"
        this.state.updateAll()
        if hasNewTag
          this.newTag = ""
        if this.newShare? and this.newShare != ""
          this.newShare = ""
        setTimeout =>
          this.closeModal()
        , 200

    closeModal: ->
      this.modalEl().modal('hide')
      setTimeout =>
        this.$parent.setEditMode(false)
      , 100
  }
})
