module V3
  class ApiController < ApplicationController
    before_action :login_required
    def photos
      @recent = BaseFile.visible.order("shot_at desc").paginate(page: params[:page], per_page: 10)
      render json: {
        data: @recent,
        meta: {
          total_pages: @recent.total_pages,
          total_count: @recent.total_entries
        }
      }
    end
  end
end
