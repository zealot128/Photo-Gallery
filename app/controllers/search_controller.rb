class SearchController < ApplicationController
  before_action :login_required

  def index
    @search = MediaSearch.new(params[:media_search])
  end
end
