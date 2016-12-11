class V2::ImageFacesController < ApplicationController
  def show
    @photo = BaseFile.find(params[:id])
  end

  def face
    @face = ImageFace.find(params[:face_id])
    @photo = @face.base_file
    similar = RekognitionClient.search_faces(@face.aws_id, threshold: 50)
    @similar = ImageFace.where('person_id is null or person_id = ?', @face.person_id).where(aws_id: similar.face_matches.map{|i| [i.face.face_id, i.similarity]}.sort_by{|a,b| -b }.map(&:first))
    @new_similar = ImageFace.where('person_id is null').where(aws_id: similar.face_matches.map{|i| [i.face.face_id, i.similarity]}.sort_by{|a,b| -b }.map(&:first))
  end

  def unassigned
    @images = ImageFace.where(person_id: nil).limit(200)
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
