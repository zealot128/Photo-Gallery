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
        binding.pry
        out = similar.face_matches.map{|i| [i.face.face_id, [i.similarity, i.face.confidence]]}.to_h
        similarities = ImageFace.where(aws_id: out.keys).tap{|i|
          i.each{|face|
            face.similarity, confidence = out[face.aws_id]
            if face.confidence.nil?
              face.confidence = confidence
              face.save
            end
          }
        }.sort_by{|a| -(a.similarity || 0)}
        render json: similarities
      }

    end
  end

  def unassigned
    @images = ImageFace.where(person_id: nil).order('created_at desc').paginate(page: params[:page], per_page: 100)
  end

  def bulk_update
    if !params[:person_name].present?
      head 422
      return
    end
    Person.where(name: params[:person_name]).first_or_create
    existing = Person.where('lower(name) = lower(?)', params[:person_name].strip).first
    person = existing || Person.create(params[:person_name])
    ImageFace.where(id: params[:face_ids]).update_all(person_id: person.id)
    # if params[:unselected_face_ids].present?
    #   ImageFace.where(id: params[:unselected_face_ids]).where(person_id: person.id).update_all person_id: nil
    # end
    render json: {}
  end
end
