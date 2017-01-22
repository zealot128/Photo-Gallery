xml.instruct!
xml.tag! "D:multistatus", "xmlns:D" => "DAV:" do
  xml.tag! "D:response" do
    xml.tag! "D:href", "/"
    xml.tag! "D:propstat" do
      xml.tag! "D:status", "HTTP/1.1 200 OK"
      xml.tag! "D:prop" do
        # xml.tag! "D:supported-method-set" do
        #   xml.tag! "D:supported-method", name: "PUT"
        #   xml.tag! "D:supported-method", name: "MKCOL"
        #   xml.tag! "D:supported-method", name: "GET"
        #   xml.tag! "D:supported-method", name: "PROPFIND"
        # end
        xml.tag! "D:displayname", "DAV"
        xml.tag! "D:creationdate", "1970-01-01T00:00:00Z"
        xml.tag! "D:getcontentlength", 0
        xml.tag! "D:getlastmodified", "Thu, 01 Jan 1970 00:00:00 GMT"
        xml.tag! "D:resourcetype" do
          xml.tag! "D:collection", nil
        end
      end
    end
  end
end

