class ZipController < ApplicationController

  def share
    Dir['tmp/share-*.zip'].each do |file|
      if File.ctime(file) < 1.week.ago
        File.unlink(file)
      end
    end
    @share = Share.find_by_token(params[:id])
    files = @share.photos.order('shot_at asc').map{|i| i.file}
    Zip::ZipFile.open("tmp/share-#{params[:id]}.zip", Zip::ZipFile::CREATE) do |zipfile|
      files.each do |file|
        next unless file.to_file
        name = file.path.split('/')[-2..-1].join('_')
        zipfile.get_output_stream(name) { |f|
          f.write file.to_file.read
        }
      end
    end
    send_file "tmp/share-#{params[:id]}.zip", filename: 'photos.zip', type: 'application/zip'
  end
end
