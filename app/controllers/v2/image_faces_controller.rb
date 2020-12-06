class V2::ImageFacesController < ApplicationController
  def show
    @photo = BaseFile.find(params[:id])
  end

  def face
    @face = ImageFace.find(params[:face_id])
    @photo = @face.base_file
    respond_to do |format|
      format.html
      format.json {
        similarities = REKOGNITION_CLIENT.find_similar_faces(@face, threshold: params[:threshold].to_i, max_faces: params[:max].to_i)
        render json: similarities
      }
    end
  end

  def unassigned
    @filter = UnassignedFilter.new
    @filter.assign_attributes(params[:unassigned_filter]) if params[:unassigned_filter]
    @image_faces = @filter.image_faces.paginate(page: params[:page], per_page: 200)
  end

  def bulk_update
    if params[:person_name].blank?
      head 422
      return
    end
    existing = Person.where('lower(name) = lower(?)', params[:person_name].strip).first
    person = existing || Person.create(name: params[:person_name])
    ImageFace.where(id: params[:face_ids]).update_all(person_id: person.id)
    render json: {
      person: person.as_json,
    }
  end

  def bulk_delete
    faces = ImageFace.where id: params[:face_ids]
    faces.destroy_all
    render json: { deletedCount: faces.length }
  end
end
