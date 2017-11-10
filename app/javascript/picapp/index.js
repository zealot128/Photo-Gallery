import Vue from 'vue/dist/vue';
import App from 'picapp/app.vue'

import Buefy from 'buefy'
import VueGallery from 'vue-gallery';

import 'buefy/lib/buefy.css'
Vue.use(Buefy)
Vue.use(VueGallery)

import infiniteScroll from 'vue-infinite-scroll'
Vue.use(infiniteScroll)

const moment = require('moment')
require('moment/locale/de')
Vue.use(require('vue-moment'), { moment })
moment.locale('de');

import 'mdi/css/materialdesignicons.css'
import store from 'picapp/store'

document.addEventListener('DOMContentLoaded', () => {
  let token = document.getElementsByName('csrf-token')[0].getAttribute('content')
  store.commit('SET_CSRF_TOKEN', token)
  const el = document.getElementById('vue-entry')
  const app = new Vue({
    // store: store,
    components: { App },
    template: '<App/>',
    store,
    el: '#vue-entry',
  })
})
