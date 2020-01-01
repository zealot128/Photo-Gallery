require 'controller_authentication'
class ApplicationController < ActionController::Base
  include ControllerAuthentication
  protect_from_forgery with: :null_session

  protected

  def shares
    Share.sorted
  end
  helper_method :shares

  def tag_counts
    BaseFile.tag_counts.reorder(:name)
  end
  helper_method :tag_counts

  def can?(subject, object)
    !!current_user
  end
  helper_method :can?

  before_action :set_locale_from_profile

  def set_locale_from_profile
    tz =
      if current_user && current_user.timezone.present?
        ActiveSupport::TimeZone[current_user.timezone]
      else
        ActiveSupport::TimeZone[Rails.configuration.time_zone]
      end
    Time.zone = tz
    I18n.locale = if current_user && current_user.locale?
                    current_user.locale
                  else
                    I18n.default_locale
                  end
  end
end
