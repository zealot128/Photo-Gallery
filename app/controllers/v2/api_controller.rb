class V2::ApiController < ApplicationController
  before_filter :login_required
  def tags
    tags = ActsAsTaggableOn::Tag.order(:name).as_json
    render json: tags
  end

  def shares
    shares = Share.order(:name).as_json
    render json: shares
  end
end
