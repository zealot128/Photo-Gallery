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

    def shares
      shares = Share.sorted.as_json
      render json: shares
    end

    def tags
      tags = ActsAsTaggableOn::Tag.order(:name).as_json
      render json: tags
    end

    def exif
      json = Rails.cache.fetch('api.exif', expires_in: 0) do
        {
          camera_models: Photo.group("(meta_data->>'model')::text").order('count_all desc').limit(30).count.delete_if { |k, _| k.blank? }.map { |k, v|
            {
              name: k,
              count: v
            }
          }
        }
      end
      render json: json
    end
  end
end
