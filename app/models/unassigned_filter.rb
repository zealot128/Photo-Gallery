class UnassignedFilter
  include ActiveModel::Model
  include FilterFormModel
  attr_accessor :confidence
  attr_accessor :from_date
  attr_accessor :to_date

  def image_faces
    sql = ImageFace.where(person_id: nil).order('created_at desc')
    if confidence.present?
      min, max = parsed(confidence)
      sql = sql.where('confidence >= ?', min) if min
      sql = sql.where('confidence <= ?', max) if max
    end
    if from_date.present?
      sql = sql.joins('photos').where('photos.shot_at >= ?', date_parse(from_date))
    end
    if to_date.present?
      sql = sql.joins('photos').where('photos.shot_at <= ?', date_parse(to_date))
    end
    sql
  end
end
