import axios from "axios"
import store from "picapp/store"

axios.defaults.baseURL = "/"
axios.defaults.withCredentials = false
axios.defaults.headers.common = {
  Accept: "application/json",
  "Content-Type": "application/json",
}

/* eslint class-methods-use-this: 0 */

class Api {
  constructor() {
    axios.defaults.headers.common["X-CSRF-Token"] = store.state.csrfToken
  }

  getPhotos(page, filter) {
    return axios.get("/v3/api/photos", {
      params: {
        ...filter,
        page,
      },
    })
  }

  getPeople() {
    return axios.get("/v3/api/people", {}).then(r => r.data)
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
    return axios.post(`/photos/${id}/rotate`, { direction })
  }

  getTags() {
    return axios.get(`/v3/api/tags.json`)
  }

  getShares() {
    return axios.get(`/v3/api/shares.json`)
  }

  getExifData() {
    return axios.get(`/v3/api/exif.json`)
  }

  updateFile(id, attributes) {
    return axios.patch(`/photos/${id}`, {
      photo: attributes,
    })
  }

  bulkUpdate(request) {
    return axios.post("/v2/bulk_update", request)
  }

  getUnassignedFaces() {
    return axios.get("/v3/api/unassigned").then(r => r.data)
  }

  getSimilarImages(face, max, threshold) {
    return axios
      .get(`/v2/faces/${face.id}`, {
        params: { max, threshold },
      })
      .then(r => r.data)
  }

  deleteFaces(faceIds) {
    return axios.delete(`/v2/faces`, {
      params: { face_ids: faceIds },
    })
  }

  setFaces(personName, faceIds, unselectedFaceIds) {
    return axios.post("/v2/assign_faces", {
      person_name: personName,
      face_ids: faceIds,
      unselected_face_ids: unselectedFaceIds,
    })
  }
}

export default Api
