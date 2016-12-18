class ApplicationController < ActionController::Base
  force_ssl if: :should_force_ssl?
  include ControllerAuthentication
  protect_from_forgery with: :null_session

  protected

  def shares
    Share.sorted
  end

  def tag_counts
    BaseFile.tag_counts.reorder(:name)
  end
  helper_method :shares
  helper_method :tag_counts

  def can?(subject, object)
    !!current_user
  end
  helper_method :can?

  def should_force_ssl?
    Rails.env.production? && request.format.html?
  end
  before_action :set_locale_from_profile

  def set_locale_from_profile
    tz =
      if current_user && current_user.timezone.present?
        ActiveSupport::TimeZone[current_user.timezone]
      else
        ActiveSupport::TimeZone[Rails.configuration.time_zone]
      end
    Time.zone = tz
    if current_user && current_user.locale?
      I18n.locale = current_user.locale
    else
      I18n.locale = I18n.default_locale
    end
  end
end
