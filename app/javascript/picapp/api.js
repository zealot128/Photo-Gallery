import axios from 'axios'
import store from 'picapp/store'

axios.defaults.baseURL = '/';
axios.defaults.withCredentials = false;
axios.defaults.Headers = { Accept: 'application/json' }

/* eslint class-methods-use-this: 0 */

class Api {
  constructor() {
    axios.defaults.headers.common['X-CSRF-Token'] = store.state.csrfToken
  }

  getPhotos(page, filter) {
    return axios.get('/v3/api/photos', {
      params: {
        ...filter,
        page
      }
    })
  }
  getPeople() {
    return axios.get('/v3/api/people', {}).then(r => r.data)
  }
  deletePhoto(id) {
    return axios.delete(`/photos/${id}`)
  }
  unDeletePhoto(id) {
    return axios.post(`/photos/${id}/undelete`)
  }
  like(id) {
    return axios.post(`/photos/${id}/like`)
  }
  unlike(id) {
    return axios.post(`/photos/${id}/unlike`)
  }
  rotate(id, direction) {
    return axios.post(`/photos/${id}/rotate`, { params: { direction } })
  }
}

export default Api
