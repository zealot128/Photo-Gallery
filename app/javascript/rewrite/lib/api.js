import axios from "axios"

axios.defaults.baseURL = "/"
axios.defaults.withCredentials = true
axios.defaults.headers.common = {
  Accept: "application/json",
  "Content-Type": "application/json",
}

/* eslint class-methods-use-this: 0 */

class Api {
  constructor(token) {
    axios.defaults.headers.common["X-CSRF-Token"] = token
  }

  getPhotos(page, filter) {
    return axios.get("/v3/api/photos", {
      params: {
        ...filter,
        page,
      },
    })
  }

  facets(filter) {
    return axios.get("/v3/api/facets", {
      params: {
        ...filter,
      },
    }).then(r => r.data)
  }

  status() {
    return axios.get("/admin/status.json").then(r => r.data)
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
    return axios.delete(`/photos/${id}/like`)
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
    }).then(r => r.data)
  }
}

export default Api

