require 'zip'
class ZipController < ApplicationController

  def share
    Dir['tmp/cache/share-*.zip'].each do |file|
      if File.ctime(file) < 1.week.ago
        File.unlink(file)
      end
    end
    filename = "tmp/cache/share-#{params[:id]}.zip"
    if !File.exists?(filename) or true
      @share = Share.find_by_token(params[:id])
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
    send_file filename, filename: 'photos.zip', type: 'application/zip'
  end
end
