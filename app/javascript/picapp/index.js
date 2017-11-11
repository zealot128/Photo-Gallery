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
  const token = document.getElementsByName('csrf-token')[0].getAttribute('content')
  store.commit('SET_CSRF_TOKEN', token)
  console.log(store);
  /* eslint no-new: 0 */
  new Vue({
    render: h => h(App),
    store,
    el: '#vue-entry',
  })
})
