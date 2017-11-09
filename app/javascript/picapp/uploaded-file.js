class UploadedFile {
  constructor(data, moment) {
    this.data = data;
    this.title = data.shot_at_formatted
    this.href = data.versions.large
    this.preview = data.versions.preview
    this.shotAt = moment(data.shot_at)
    if (data.type == 'Video') {
      this.type = 'video/mp4'
      this.poster = this.preview
    } else {
      this.type = 'image/jpeg'
      this.thumbnail = data.versions.thumb
    }
  }
}

export default UploadedFile

