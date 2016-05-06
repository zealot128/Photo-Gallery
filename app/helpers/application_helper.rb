module ApplicationHelper

  def json(object)
    raw object.to_json
  end

  def qrcode_image_url(link)
    qrcode = RQRCode::QRCode.new(link)
    qrcode.as_png.to_data_url
  end

end
