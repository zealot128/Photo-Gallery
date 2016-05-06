class SharesController < ApplicationController
  before_filter :login_required, except: "show"

  def show
    @share = Share.find_by!(token: params[:id])
    @photos = @share.photos.order("shot_at desc")
  end

  def destroy
    @share = Share.find_by_token(params[:id])
    @share.destroy
    respond_to do |f|
      f.js
    end
  end

  def download
  end

  def bulk_update
    binding.pry
    case params[:choice]
    when "tag"
      tag = params[:bulk][:tag]
      photos = BaseFile.where(id: params["photos"])
      photos.map{|i|
        i.tag_list << tag
        i.slow_callbacks = false
        i.save! validate: false
        i.slow_callbacks = true
      }
      tag = ActsAsTaggableOn::Tag.where(name: tag).first
    when "share"
      if params["new_share_name"].present?
        @share = Share.create!(name: params["new_share_name"])
      else
        @share = Share.find(params["bulk"]["share_id"])
      end
      photo_ids = BaseFile.where(id: params["photos"]).pluck :id
      @share.photo_ids = (@share.photo_ids + photo_ids).uniq
      @share.save!
      render json: {status: "OK", url: share_url(@share)}
    else
      render json: { status: "error", message: "Choose Share or Tag"}
    end
  end
end
