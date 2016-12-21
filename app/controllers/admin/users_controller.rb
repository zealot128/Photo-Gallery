class Admin::UsersController < ApplicationController
  before_filter :admin_required

  def index
    @users = User.all
  end

  def new
    @user = User.new
  end

  def create
    @user = User.new(params[:user].permit!)
    if @user.save
      redirect_to '/admin/users', notice: "Created!"
    else
      render :new
    end
  end

  def edit
    @user = User.find(params[:id])
  end

  def update
    @user = User.find(params[:id])
    if @user.update(params[:user].permit!)
      redirect_to '/admin/users', notice: "Updated!"
    else
      render :new
    end
  end

  def destroy
    @user = User.find(params[:id])
    @user.destroy
    redirect_to '/admin/users', notice: "deleted!"
  end
end
