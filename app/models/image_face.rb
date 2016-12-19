# == Schema Information
#
# Table name: image_faces
#
#  id           :integer          not null, primary key
#  bounding_box :json
#  file         :string
#  base_file_id :integer
#  person_id    :integer
#  aws_id       :uuid
#  created_at   :datetime         not null
#  updated_at   :datetime         not null
#

class ImageFace < ApplicationRecord
  belongs_to :base_file
  belongs_to :person

  after_create :crop_bounding_box, :auto_assign_person
  mount_uploader :file, MontageUploader

  # For image face controller transient value
  attr_accessor :similarity

  after_destroy do
    begin
      RekognitionClient.delete_faces(self.aws_id)
    rescue Exception => e
      ExceptionNotifier.notify_exception(e) if defined?(ExceptionNotifier)
      p e if !Rails.env.production?
      nil
    end
  end

  def crop_bounding_box
    version = base_file.file.versions[:large]
    version.cache!
    image = MiniMagick::Image.open(version.path)
    image_width = image.width
    image_height = image.height
    w = (bounding_box['width'] * image_width).round
    h = (bounding_box['height'] * image_height).round
    left = (bounding_box['left'] * image_width).round
    top = (bounding_box['top'] * image_height).round
    image.crop("#{w}x#{h}+#{left}+#{top}")
    image.resize 'x100>'
    self.file = File.open(image.path)
    self.save
  end

  def auto_assign_person
    if !person
      similar = RekognitionClient.search_faces(aws_id, threshold: 80, max_faces: 15)
      if similar.face_matches.count >= 5
        face_histogram = ImageFace.where(aws_id: similar.face_matches.map{|i| i.face.face_id }).map(&:person_id).compact.group_by(&:itself).map{|a,b|[a,b.count]}.to_h
        if face_histogram.length == 1 && face_histogram.values.first >= 5
          person_id = face_histogram.keys.first
          update person_id: person_id
        end
      end
    end
  end

  def as_json(opts={})
    {
      id: id,
      preview: file.url,
      bounding_box: bounding_box,
      similarity: similarity,
      confidence: confidence,
      person_id: person_id,
      person_name: person.try(:name)
    }
  end
end
