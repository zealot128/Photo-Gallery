require "ruby-progressbar"

sql = BaseFile.where(file_data: nil)
pbar = ProgressBar.create(total: sql.count)

sql.find_each do |bf|
  pbar.increment
  bf.migrate!
  bf.instance_exec do
    attacher = file_attacher
    attacher.file.open do
      attacher.refresh_metadata!(background: true) # extract metadata
      if bf.is_a?(Video)
        attacher.create_derivatives
      end
    end
  end
  bf.save
rescue StandardError => e
  warn e.inspect
  warn "File: #{bf.id}"
end

