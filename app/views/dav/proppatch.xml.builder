xml.instruct!
xml.tag! "D:multistatus", "xmlns:D" => "DAV:" do
  xml.tag! "D:response" do
    xml.tag! "D:href", "/" + params[:filename]
    xml.tag! "D:propstat" do
      xml.tag! "D:status", "HTTP/1.1 200 OK"
      xml.tag! "D:prop" do
      end
    end
  end
end

