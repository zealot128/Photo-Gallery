import Vue from 'vue/dist/vue';
import Vuex from 'vuex'
// import isEqual from 'lodash/isEqual'

Vue.use(Vuex)

// const { currentUser } = window

const debug = process.env.NODE_ENV !== 'production'

const store = new Vuex.Store({
  state: {
    csrfToken: null,
  },
  mutations: {
    SET_CSRF_TOKEN(state, token) {
      state.csrfToken = token
    },
  },
  actions: {
  },
  strict: debug
})

export default store;
