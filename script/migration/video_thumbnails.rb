puts "#{Video.count} Videos to process..."
Video.find_each do |video|
  begin
    print '.'
    video.create_preview_thumbnails
  rescue Aws::S3::Errors::NoSuchKey
    puts "ERROR: #{video.id} not found on aws - deleted?"
  end
end
