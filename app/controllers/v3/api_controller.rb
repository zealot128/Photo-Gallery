module V3
  class ApiController < ApplicationController
    before_action :login_required
    def photos
      search = V3::Search.new(params.transform_keys(&:underscore).permit!.except('controller', 'action').to_h)
      @recent = search.media
      render json: {
        data: @recent,
        facets: {
          labels: search.label_facets,
        },
        meta: {
          current_page: search.page,
          total_pages: @recent.total_pages,
          total_count: @recent.total_entries
        }
      }
    end

    def people
      @people = Person.all
      render json: @people
    end
  end
end
