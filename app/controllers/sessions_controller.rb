class SessionsController < ApplicationController

  def new
  end

  def create
    user = User.authenticate(params[:login], params[:password])
    if user
      session[:user_id] = user.id
      cookies.signed[:user_id] = user.id
      redirect_to_target_or_default '/photos', notice: "Erfolgreich eingeloggt"
    else
      flash.now[:alert] = "Invalid login or password."
      render :action => 'new'
    end
  end

  def destroy
    session[:user_id] = nil
    cookies.signed[:user_id] = nil
    redirect_to root_url, notice: "Erfolgreich ausgeloggt."
  end
end
