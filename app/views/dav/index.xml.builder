xml.multistatus xmlns: "DAV:" do
  xml.response do
    xml.href root_url + "dav"
    xml.propstat do
      xml.prop do
        xml.tag! "supported-method-set" do
          xml.tag! "supported-method", name: "PUT"
        end
      end
    end
  end
end

