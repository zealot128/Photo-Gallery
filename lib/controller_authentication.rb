module ControllerAuthentication
  def self.included(controller)
    controller.send :helper_method, :current_user, :logged_in?, :redirect_to_target_or_default, :admin?
  end

  def current_user
    @current_user ||= User.find(session[:user_id]) if session[:user_id] || @current_user
  end

  def login_by_token
    if (auth = request.headers.to_h['HTTP_AUTHORIZATION']) and (token = auth[/^Bearer (.+)$/, 1])
      if app_token = AppToken.includes(:user).find_by(token: token)
        app_token.update_column :last_used, Time.zone.now
        @current_user = app_token.user
      else
        render json: { error: "Login failed" }, status: 400
      end
    end
  end

  def logged_in?
    current_user
  end

  def admin?
    logged_in? && current_user.admin?
  end

  def login_required
    unless logged_in?
      store_target_location
      redirect_to login_url, alert: "You must first log in or sign up before accessing this page."
    end
  end

  def admin_required
    login_required
    if logged_in? and !current_user.admin?
      render status: 403, text: "You are not authorized to access that page", layout: true
    end
  end

  def redirect_to_target_or_default(default, *args)
    redirect_to(session[:return_to] || default, *args)
    session[:return_to] = nil
  end

  private

  def store_target_location
    if request.format.html?
      session[:return_to] = request.url
    end
  end
end
