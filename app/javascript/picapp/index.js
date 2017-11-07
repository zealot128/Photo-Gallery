import Vue from 'vue/dist/vue';
import App from 'picapp/app.vue'

import Buefy from 'buefy'
import VueGallery from 'vue-gallery';
import axios from 'axios'
import VueAxios from 'vue-axios'

import 'buefy/lib/buefy.css'
Vue.use(Buefy)
Vue.use(VueGallery)


axios.defaults.baseURL = '/';
axios.defaults.withCredentials = false;
axios.defaults.Headers = { Accept: 'application/json' }

Vue.prototype.$http = axios;
Vue.use(VueAxios, axios);

import 'mdi/css/materialdesignicons.css'

document.addEventListener('DOMContentLoaded', () => {
  let token = document.getElementsByName('csrf-token')[0].getAttribute('content')
  axios.defaults.headers.common['X-CSRF-Token'] = token
  const el = document.getElementById('vue-entry')
  const app = new Vue({
    // store: store,
    components: { App },
    template: '<App/>',
    el: '#vue-entry',
  })
})
