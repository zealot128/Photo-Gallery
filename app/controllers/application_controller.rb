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
end
