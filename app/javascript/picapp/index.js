import Vue from 'vue/dist/vue';
import App from 'picapp/app.vue'

import Buefy from 'buefy'
import VueGallery from 'vue-gallery';

import 'buefy/dist/buefy.css'
Vue.use(Buefy)
Vue.use(VueGallery)

import infiniteScroll from 'vue-infinite-scroll'
Vue.use(infiniteScroll)

import VueClip from 'vue-clip'
Vue.use(VueClip)

const moment = require('moment')
require('moment/locale/de')
Vue.use(require('vue-moment'), { moment })
moment.locale('de');

const vueSmoothScroll = require('vue-smoothscroll');
Vue.use(vueSmoothScroll);

import 'mdi/css/materialdesignicons.css'
import store from 'picapp/store'

document.addEventListener('DOMContentLoaded', () => {
  if (!document.getElementById('vue-entry')) {
    return
  }
  const token = document.getElementsByName('csrf-token')[0].getAttribute('content')
  store.commit('SET_CSRF_TOKEN', token)
  /* eslint no-new: 0 */
  new Vue({
    render: h => h(App),
    store,
    el: '#vue-entry',
  })
})
