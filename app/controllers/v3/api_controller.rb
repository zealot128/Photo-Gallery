module V3
  class ApiController < ApplicationController
    skip_before_action :verify_authenticity_token
    before_action :login_by_token
    before_action :login_required, except: :sign_in

    def sign_in
      user = User.authenticate(params[:username], params[:password])
      if user
        token = user.app_tokens.create(user_agent: request.user_agent)
        render json: { token: token.token }, status: :created
      else
        render json: { error: "User not found" }, status: :unauthorized
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

    def facets
      search = V3::Search.new(params.transform_keys(&:underscore).permit!.except('controller', 'action').to_h)
      render json: {
        labels: search.label_facets.map { |k, v| { name: k, count: v } },
        people: search.people_facets.map { |k| { person: k, count: k.image_count } },
        cameras: search.camera_facets.map { |k, v| { name: k, count: v } },
        apertures: search.aperture_facets.map { |k, v| { name: k, count: v } },
      }
    end

    def overview
      search = V3::Search.new(params.transform_keys(&:underscore).permit!.except('controller', 'action').to_h)
      render json: {
        months: search.overview
      }
    end

    def people
      @people = Person.select('people.*, (select count(*) from image_faces where image_faces.person_id = people.id) as photo_count')
      render json: @people.sort_by { |i| [-(i.photo_count**(1/5r)).round, i.name] }
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
        base = Photo.visible.limit(30).order('count_all desc')
        {
          camera_models: base.
            group("jsonb_extract_path_text(file_data, 'metadata', 'exif', 'model')").
            count.
            delete_if { |k, _| k.blank? }.
            map { |k, v| { name: k, count: v } },
          aperture: base.
            group("jsonb_extract_path_text(file_data, 'metadata', 'exif', 'aperture')").
            count.
            delete_if { |k, _| k.blank? }.
            map { |k, v| { name: k, count: v } }
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
