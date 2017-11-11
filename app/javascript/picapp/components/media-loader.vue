<template lang="pug">
  div(v-infinite-scroll="loadMore" infinite-scroll-distance="100" infinite-scroll-immediate-check infinite-scroll-disabled="disableScrollWatch")
    b-loading(:active.sync="loadingItems" v-if='loadingItems' :canCancel="true")
    transition(name="slide-fade"): slot(v-if='!loadingItems || value.length > 0')
    transition(name="slide-fade")
      b-message(title="Fehler beim Laden" type="is-danger" v-if='loadingError')
        button.button.is-primary(@click='retry') Erneut versuchen
        br
        |{{loadingError}}

</template>
<script>
import Api from 'picapp/api';
import UploadedFile from 'picapp/uploaded-file';
export default {
  props: {
    value: {
      type: Array,
      required: true
    },
    disableAutoLoading: {
      type: Boolean,
      required: true
    },
    filter: {
      type: Object,
      required: true
    }
  },
  data() {
    return {
      loadingItems: true,
      loadingError: null,
      pagination: {
        currentPage: 1,
        totalPages: 1,
        totalCount: 0
      },
    }
  },
  watch: {
    filter() { this.initialLoad() }
  },
  computed: {
    api() { return new Api() },
    disableScrollWatch() {
      return this.loadingItems || this.disableAutoLoading;
    },
  },
  created() {
    this.initialLoad()
  },
  methods: {
    loadMore() {
      if (this.pagination.totalPages > this.pagination.currentPage) {
        this.loadingItems = true
        this.loadPage(this.pagination.currentPage + 1, this.filter)
      }
    },
    initialLoad() {
      this.loadPage(1)
    },
    retry() {
      this.loadPage(this.pagination.currentPage, this.filter)
    },
    loadPage(page) {
      this.loadingError = null
      this.loadingItems = true
      this.api.getPhotos(page, this.filter).then((r) => {
        let photos;
        if (page === 1) {
          photos = r.data.data.map(d => new UploadedFile(d, this.$moment))
        } else {
          photos = this.value.concat(r.data.data.map(d => new UploadedFile(d, this.$moment)))
        }
        this.$emit('input', photos)
        this.pagination.currentPage = page
        this.pagination.totalPages = r.data.meta.total_pages
        this.pagination.totalCount = r.data.meta.total_count
        this.loadingItems = false
        if (this.$refs.gallery) {
          this.galleryControlIndex = null
        }
      }).catch((error) => {
        this.loadingError = error.response
        this.loadingItems = false
      })
    },
  }
};
</script>
<style>
.slide-fade-enter-active {
  transition: all .3s ease;
}
.slide-fade-leave-active {
  transition: all .8s cubic-bezier(1.0, 0.5, 0.8, 1.0);
}
.slide-fade-enter, .slide-fade-leave-to {
  transform: translateX(10px);
  opacity: 0;
}
</style>
