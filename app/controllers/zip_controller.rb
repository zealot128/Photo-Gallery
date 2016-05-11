require 'zip'
class ZipController < ApplicationController

  def share
    Dir['tmp/cache/share-*.zip'].each do |file|
      if File.ctime(file) < 1.week.ago
        File.unlink(file)
      end
    end
    filename = "tmp/cache/share-#{params[:id]}.zip"
    @share = Share.find_by_token(params[:id])
    if !File.exists?(filename) or File.ctime(filename) < @share.updated_at
      files = @share.photos.order('shot_at asc').map{|i| i.file}
      Zip::ZipFile.open(filename, Zip::ZipFile::CREATE) do |zipfile|
        files.each do |file|
          to_file = file.file.to_file

          next unless to_file
          name = file.path.split('/')[-2..-1].join('_')
          zipfile.get_output_stream(name) { |f|
            if to_file.respond_to?(:read)
              f.write to_file.read
            else
              f.write to_file.get.body.read
            end
          }
        end
      end
    end
    response.headers['Content-Length'] = File.size(filename).to_s
    response.headers["Accept-Ranges"] = "bytes"

    send_file filename, filename: "photos-#{@share.updated_at.to_s(:db)}.zip", type: 'application/zip', range: true
  end
end
