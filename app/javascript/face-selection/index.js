import Vue from 'vue/dist/vue';
import App from 'face-selection/app'

import store from 'picapp/store'

document.addEventListener('DOMContentLoaded', () => {
  if (!document.getElementById('face-selection')) {
    return
  }
  const token = document.getElementsByName('csrf-token')[0].getAttribute('content')
  store.commit('SET_CSRF_TOKEN', token)
  /* eslint no-new: 0 */
  new Vue({
    render: h => h(App),
    store,
    el: '#face-selection',
  })
})
