import * as Vue from 'vue/dist/vue.common.js';
import Vuex from 'vuex/dist/vuex.esm';

Vue.use(Vuex)

const { currentUser } = window

export const store = new Vuex.Store({
  state: {
    csrfToken: null,
    filter: {
    },
  },
  mutations: {
    SET_CSRF_TOKEN(state, token) {
      state.csrfToken = token
    }
  }
})

export default store;
