import axios from 'axios'
import store from 'picapp/store'

axios.defaults.baseURL = '/';
axios.defaults.withCredentials = false;
axios.defaults.Headers = { Accept: 'application/json' }

class Api {
  constructor() {
    axios.defaults.headers.common['X-CSRF-Token'] = store.state.csrfToken
  }

  getPhotos(page) {
    return axios.get('/v3/api/photos', {
      params: {
        ...store.state.filter,
        page: page
      }
    })
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
    return axios.post(`/photos/${id}/rotate`, { params: { direction: direction }})
  }
}

export default Api
