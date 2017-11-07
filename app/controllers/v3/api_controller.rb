module V3
  class ApiController < ApplicationController
    before_action :login_required
    def photos
      @recent = BaseFile.visible.order("created_at desc").paginate(page: nil, per_page: 30)
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
