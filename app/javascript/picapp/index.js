import Vue from 'vue/dist/vue';
import App from 'picapp/app.vue'

import Buefy from 'buefy'
import VueGallery from 'vue-gallery';
import 'buefy/lib/buefy.css'
Vue.use(Buefy)
Vue.use(VueGallery)

import 'mdi/css/materialdesignicons.css'

document.addEventListener('DOMContentLoaded', () => {
  const el = document.getElementById('vue-entry')
  const app = new Vue({
    // store: store,
    components: { App },
    template: '<App/>',
    el: '#vue-entry',
  })
})
