class Photo < BaseFile
  mount_uploader :file, ImageUploader
  # has_attached_file :file, styles: {
  #   preview:  "300x300",
  #   thumb:  "30x30",
  #   medium: "500x500>",
  #   large:  "1000x1000>"
  # },
  # path:   ":rails_root/public/photos/:style/:date/:basename.:extension",
  # url:    "/photos/:style/:date/:basename.:extension",
  # convert_options: { all: '-auto-orient' }


  include PhotoMetadata

  before_save do
    if self.shot_at_changed? and self.shot_at_was.present?
      move_file_after_shot_at_changed
    end
    self.day = Day.date self.shot_at
  end

  def self.parse_date(file)
    date = nil
    begin
      meta = EXIFR::JPEG.new(file.path)
      date = meta.exif[:date_time] || meta.exif[:date_time_original] rescue nil
    rescue EXIFR::MalformedJPEG
    end
    if not date
      if file.original_filename[/(\d{4})[\-_\.](\d{2})[\-_\.](\d{2})/]
        date = Date.parse "#$1-#$2-#$3"
      else
        Rails.logger.warn "No Date found for file #{file.original_filename}. taking mtime"
        date = file.mtime rescue Date.today
      end
    end
    if date.is_a? String
      case date
      # correction for exif from hd cam
      when /^(\d{4}):(\d{1,2}):(\d{1,2})/
        date = Date.parse("#$1-#$2-#$3")
      else
        date = Date.parse(date)
      end
    end
    date
  end

  def self.create_from_upload(file, current_user)
    photo = Photo.new
    transaction do
      date = Photo.parse_date(file)
      begin
        meta = EXIFR::JPEG.new(file.path)
        if meta.gps
          photo.lat = meta.gps.latitude
          photo.lng = meta.gps.longitude
        end
      rescue EXIFR::MalformedJPEG
      end
      photo.shot_at = date
      photo.user = current_user
      photo.file = file
      photo.update_gps
      photo.save
    end
    photo
  end

  def rotate!(direction)
    degrees =  case direction.to_sym
               when :left
                 -90
               when :flip
                 180
               else
                 90
               end
    cmd = "mogrify -rotate #{degrees} #{Shellwords.escape(file.path)}"
    `#{cmd}`
    self.fingerprint = nil
    file.recreate_versions!
    save
  end

  def self.search_with_query_syntax(q, opts={})
    r = Photo.search q, opts.merge(execute: false)
    r.body[:query][:dis_max][:queries] << { query_string: {:fields=>["_all"], :query=> q} }
    r.execute
    r
  end

  def self.grouped
    days = Photo.all.group_by{|i|i.shot_at.to_date}.sort_by{|a,b| a}.reverse
    #  [datum, [items]] ...
    #  [month, [ [datum, items], ...

    days.group_by{|day, items| Date.parse day.strftime("%Y-%m-01")}
  end

  # @deprecated
  def self.days_of_year(year)
    days = Photo.where(:year => year).
      group_by{|i|i.shot_at.to_date}.
      sort_by{|a,b| a}.reverse
    days.group_by{|day, items| day.month}
  end

  def self.years
    Photo.uniq.order("year desc").pluck(:year)
  end

  include ActionView::Helpers::NumberHelper

  def as_json(op={})
    {
      id:                   id,
      location:             location,
      shot_at:              shot_at,
      shot_at_formatted:    I18n.l(shot_at, format: :short),
      original:             file.url,
      file_size:            file.size,
      file_size_formatted:  number_to_human_size(file.size),
      caption:              caption,
      description:          description,
      exif:                 exif
    }
  end

  private

  def move_file_after_shot_at_changed
    @old_day = self.day
    old = shot_at_was
    new = shot_at
    old_str = old.strftime("%Y-%m-%d")
    new_str = new.strftime("%Y-%m-%d")
    return if old_str == new_str

    ([[:original, file]] + file.versions.to_a ).each do |key,version|
      from = version.path.gsub(new_str, old_str).gsub(%r{/#{new.year.to_s}/}, "/#{old.year.to_s}/")
      to = version.path.gsub(old_str, new_str).gsub(%r{/#{old.year.to_s}/}, "/#{new.year.to_s}/")
      Rails.logger.info "[photo] Moving #{from} -> #{to}"
      Rails.logger.info "  #{from} exists? -> #{File.exists?(from)}"
      Rails.logger.info "  #{to}   exists? -> #{File.exists?(to)}"

      case version.file.class.to_s
      when 'CarrierWave::Storage::Fog::File'
        self.shot_at = old
        version.cache!
        self.shot_at = new
        version.store!
      else
        version.cache!
        version.store!
      end
    end
  end
end
