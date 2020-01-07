// import Vue from 'vue';
// import App from 'rewrite/App.vue'

// import store from 'picapp/store'
// import infiniteScroll from 'vue-infinite-scroll'
// Vue.use(infiniteScroll)

// const moment = require('moment')
// require('moment/locale/de')
// Vue.use(require('vue-moment'), { moment })
// moment.locale('de');

// import Vuetify from 'vuetify'
// import 'vuetify/dist/vuetify.min.css'

// Vue.use(Vuetify)

// const opts = {}
// const vuetify = new Vuetify(opts)


// document.addEventListener('DOMContentLoaded', () => {
//   const token = document.getElementsByName('csrf-token')[0].getAttribute('content')
//   store.commit('SET_CSRF_TOKEN', token)
//   /* eslint no-new: 0 */
//   new Vue({
//     el: document.getElementsByTagName('main-app')[0],
//     render: h => h(App),
//     vuetify,
//     store,
//   })
// })

import App from './App.svelte';
import './style.scss';

document.addEventListener('DOMContentLoaded', () => {
  const token = document.getElementsByName('csrf-token')[0].getAttribute('content')
  const app = new App({
    target: document.getElementsByTagName('main-app')[0],
    props: {
      csrfToken: token,
    }
  });
})

