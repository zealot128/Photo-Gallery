module ApplicationHelper

  def json(object)
    raw object.to_json
  end

end
