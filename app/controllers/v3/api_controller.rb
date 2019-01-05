module V3
  class ApiController < ApplicationController
		skip_before_action :verify_authenticity_token
    before_action :login_by_token
    before_action :login_required, except: :sign_in

    def sign_in
      user = User.authenticate(params[:username], params[:password])
      if user
        token = user.app_tokens.create(user_agent: request.user_agent)
        render json: { token: token.token }, status: 201
      else
        render json: { error: "User not found" }, status: 401
      end
    end

    def photos
      search = V3::Search.new(params.transform_keys(&:underscore).permit!.except('controller', 'action').to_h)
      @recent = search.media
      render json: {
        data: @recent,
        facets: {
          labels: search.label_facets,
        },
        meta: {
          current_page: search.page || 1,
          total_pages: @recent.total_pages,
          total_count: @recent.total_entries
        }
      }
    end

    def overview
      search = V3::Search.new(params.transform_keys(&:underscore).permit!.except('controller', 'action').to_h)
      render json: {
        months: search.overview
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
      json = Rails.cache.fetch('api.exif', expires_in: 15.minutes) do
        groups = Photo.group("(regexp_replace(meta_data::text, '\\\\u0000', '', 'g'))::json->>'model'")
          .order('count_all desc').limit(30).count.delete_if { |k, _| k.blank? }
        {
          camera_models: groups.map { |k, v|
            { name: k, count: v }
          }
        }
      end
      render json: json
    end

    def unassigned
      @filter = UnassignedFilter.new
      @filter.assign_attributes(params[:unassigned_filter]) if params[:unassigned_filter]
      @image_faces = @filter.image_faces.paginate(page: params[:page], per_page: 200)
      render json: @image_faces
    end
  end
end
