class Video < BaseFile
  mount_uploader :file, VideoUploader


  def exif
    {
      duration: (meta_data || {}).fetch("ffprobe", {}).fetch("duration", 0).to_f.round
    }
  end

  def self.create_from_upload(file, user)
    r = `ffprobe #{Shellwords.escape(file.path)} -show_format -print_format json 2> /dev/null`
    p r
    if $?.success?
      meta_data = JSON.load(r)['format']
    else
      Rails.logger.error 'Error running ffprobe, make sure ffmpeg is installed'
      meta_data = { 'tags' => {} }
    end
    p meta_data

    meta_date = meta_data['tags']['creation_time']
    date = FileDateParser.new(file: file, user: user, exif_date: meta_date).parsed_date
    video = Video.new
    video.shot_at = date
    video.user = user
    video.file = file
    video.meta_data = { ffprobe: meta_data }
    video.save
    video
  end
end
