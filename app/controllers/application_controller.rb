class ApplicationController < ActionController::Base
  include ControllerAuthentication
  protect_from_forgery

  protected

  def shares
    Share.sorted
  end

  def tag_counts
    BaseFile.tag_counts.reorder(:name)
  end
  helper_method :shares
  helper_method :tag_counts
end
