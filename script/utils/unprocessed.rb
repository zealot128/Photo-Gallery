# All images without md5 are handled:
# * reprocess and save if missed somehow
# * destroy if duplicate md5 or already missing on storage
BaseFile.where(md5: nil).each{|i|
  begin
    puts i.id
    i.file.recreate_versions!
    if !i.save
      i.destroy
    end
  rescue Aws::S3::Errors::NoSuchKey
    i.destroy
  end
}
