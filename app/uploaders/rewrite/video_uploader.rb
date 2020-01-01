module Rewrite
  class VideoUploader < Rewrite::BaseFileUploader
    add_metadata :exif do |io, derivate: nil, **options|
      next unless options[:background]
      next unless derivate == nil

      MetaDataParser.new(io).exif
    end

    add_metadata :ffprobe do |io, derivate: nil, **options|
      next unless options[:background]
      next unless derivate == nil

      movie = Shrine.with_file(io) { |file| FFMPEG::Movie.new(file.path) }

      {
        "duration" => movie.duration,
        "tags" => movie.metadata.dig(:format, :tags)
      }
    end

    Attacher.derivatives do |original|
      movie = FFMPEG::Movie.new(original.path)

      preview = Tempfile.new ["preview", ".jpg"]
      movie.screenshot(preview.path, resolution: '300x300', preserve_aspect_ratio: :width)

      thumb = Tempfile.new ["thumb", ".jpg"]
      movie.screenshot(thumb.path, resolution: '30x30', preserve_aspect_ratio: :width)

      user_name = File.basename(original, File.extname(original))
      large = Tempfile.new [user_name, ".jpg"]
      movie.transcode(large.path,
                      video_codec: "libx264",
                      audio_codec: Setting['audio_codec'],
                      resolution: '800x500',
                      preserve_aspect_ratio: :width,
                      threads: 2)


      duration = movie.duration
      number_of_thumbnails = [duration.to_i**(1/2r), 5].min.round
      thumbnail_every_second = duration.to_f / number_of_thumbnails
      points = number_of_thumbnails.times.map { |i| (thumbnail_every_second * i).round }

      screenshots =
        points.map { |ss| [ss, Tempfile.new(["screenshot-#{ss}-", ".jpg"])] }.each { |ss, t|
          movie.screenshot(t.path, seek_time: ss, resolution: '300x300', preserve_aspect_ratio: :width)
        }.map(&:last)

      {
        preview: preview,
        thumb: thumb,
        large: large,
        screenshots: screenshots,
      }
    end
  end
end
