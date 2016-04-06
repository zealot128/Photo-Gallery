class Video < BaseFile
  mount_uploader :file, VideoUploader
  def self.create_from_upload(file, user)
    r = `ffprobe #{Shellwords.escape(file.path)} -show_format -print_format json 2> /dev/null`
    meta_data = JSON.load(r)['format']

    date = meta_data['tags']['creation_time']
    if !date and file.original_filename[/(\d{4})[\-_\.](\d{2})[\-_\.](\d{2})/]
      date = Date.parse "#$1-#$2-#$3"
    else
      date = file.mtime rescue Date.today
    end

    video = Video.new
    video.shot_at = date
    video.user = user
    video.file = file
    video.save
    video
  end
end
