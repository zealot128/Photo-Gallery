class SessionsController < ApplicationController
  def new
  end

  def create
    user = User.authenticate(params[:login], params[:password])
    if user
      session[:user_id] = user.id
      if params[:remember_me] == '1'
        cookies.signed[:user_id] = { value: user.id, expires: 1.month.from_now }
      end
      redirect_to_target_or_default '/v4', notice: "Erfolgreich eingeloggt"
    else
      flash.now[:alert] = "Invalid login or password."
      render :new
    end
  end

  def destroy
    session[:user_id] = nil
    cookies.signed[:user_id] = nil
    redirect_to root_url, notice: "Erfolgreich ausgeloggt."
  end
end
