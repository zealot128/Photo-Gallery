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
        render json: {status: "OK"}
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
end
