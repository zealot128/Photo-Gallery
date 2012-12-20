xml.instruct!
xml.rss do
  xml.channel do
    xml.title "#{I18n.t("title")}"
    @photos.each do |photo|
      xml.item do
        url = URI.join(@host, photo.file.url(:medium))
        xml.link URI.join(@host, photo.file.url(:large))
        xml.description "<img src='#{url}'/>"
        xml.enclosure url: url, type: photo.file.content_type
      end
    end
  end
end
