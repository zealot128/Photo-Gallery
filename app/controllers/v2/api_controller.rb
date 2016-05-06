class V2::ApiController < ApplicationController
  before_filter :login_required

  def tags
    tags = ActsAsTaggableOn::Tag.order(:name).as_json
    render json: tags
  end

  def shares
    shares = Share.sorted.as_json
    render json: shares
  end

  def bulk_update
    bu = BulkUpdate.new(params, current_user)
    bu.save
    render json: bu.files
  end
end
