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
        similar = RekognitionClient.search_faces(@face.aws_id, threshold: params[:threshold].to_i, max_faces: params[:max].to_i)
        out = similar.face_matches.map { |i| [i.face.face_id, [i.similarity, i.face.confidence]] }.to_h
        similarities = ImageFace.where(aws_id: out.keys).tap { |i|
          i.each { |face|
            face.similarity, confidence = out[face.aws_id]
            if face.confidence.nil?
              face.confidence = confidence
              face.save
            end
          }
        }.sort_by { |a| -(a.similarity || 0) }
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
