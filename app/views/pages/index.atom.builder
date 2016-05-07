atom_feed :language => 'en-US' do |feed|
  feed.title I18n.t("title")
  feed.updated @photos.first.updated_at
  @photos.each do |photo|
    url = URI.join(root_url, photo.file.url(:medium))
    feed.entry(photo, url: url)  do |entry|
      entry.title photo.shot_at
      entry.url URI.join(root_url, photo.file.url(:large))
      entry.content "<img src='#{url}'/>", type: "html"
      entry.enclosure url: url, type: photo.mime_type
    end
  end
end
