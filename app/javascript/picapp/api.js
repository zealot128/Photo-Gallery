class Api {
  constructor(http) {
    this.http = http
  }

  getPhotos(page) {
    return this.http.get('/v3/api/photos', {
      params: {
        page: page
      }
    })
  }
}

export default Api
