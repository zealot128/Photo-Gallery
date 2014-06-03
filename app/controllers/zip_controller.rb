require 'zip'
class ZipController < ApplicationController

  def share
    Dir['tmp/share-*.zip'].each do |file|
      if File.ctime(file) < 1.week.ago
        File.unlink(file)
      end
    end
    filename = "tmp/share-#{params[:id]}.zip"
    if !File.exists?(filename)
      @share = Share.find_by_token(params[:id])
      files = @share.photos.order('shot_at asc').map{|i| i.file}
      Zip::ZipFile.open(filename, Zip::ZipFile::CREATE) do |zipfile|
        files.each do |file|
          next unless file.to_file
          name = file.path.split('/')[-2..-1].join('_')
          zipfile.get_output_stream(name) { |f|
            f.write file.to_file.read
          }
        end
      end
    end
    send_file filename, filename: 'photos.zip', type: 'application/zip'
  end
end
