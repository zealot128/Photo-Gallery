class SharesController < ApplicationController
  before_filter :login_required, except: "show"
  def new
    @share = Share.new
    render layout: false if request.xhr?
  end

  def index
    @shares = Share.order(:name)
    @share = Share.new

  end

  def create
    if @share = Share.create(params[:share])
      if request.xhr?
        render json: {status: "OK", data: @share}
      else
        redirect_to shares_path
      end
    else
      if request.xhr?
        render json: {status: "error", data: @share.errors.full_messages}
      else
        render :new
      end
    end
  end

  def show
    @share = Share.find_by_token(params[:id])
    @month_names = ["","Jan","Feb","Mar", "Apr", "Mai", "Jun", "Jul", "Aug", "Sep", "Nov", "Dez"]
    raise ActiveRecord::RecordNotFound if @share.nil?
  end

  def options

  end

  def destroy
    @share = Share.find_by_token(params[:id])
    @share.destroy
    respond_to do |f|
      f.js
    end
  end


  def bulk_add
    from = Date.parse params[:date]
    to   = from + 1
    @photos = Photo.where(shot_at: from..to)
    render  layout: false
  end

  def bulk_update
    if params["new_share_name"].present?
      @share = Share.create! name: params["new_share_name"]
    else
      @share = Share.find(params["bulk"]["share_id"])
    end
    photo_ids = Photo.where(:id => params["photos"]).pluck :id
    @share.photo_ids = (@share.photo_ids + photo_ids).uniq
    @share.save!
    render json: {status: "OK", url: share_url(@share)}
  end
end
