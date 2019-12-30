class Photo::MetaDataJob < ApplicationJob
  queue_as :default

  def perform(photo)
    file = photo.file
    unless file.cached?
      file.cache!
    end
    path = file.path
    photo.meta_data ||= {}
    photo.meta_data = MetaDataParser.new(path).as_json
    photo.aperture = case photo.meta_data['f_number']
                     when %r{(\d+)/(\d+)} then Rational(Regexp.last_match(1).to_i, Regexp.last_match(2).to_i).to_f
                     when nil, "" then nil
                     else photo.meta_data['f_number'].to_f
                     end
    photo.fingerprint = begin
                          Phashion::Image.new(path).fingerprint
                        rescue StandardError
                          nil
                        end
    photo.save(validate: false)
    # Do something later
    if !photo.rekognition_labels_run and Setting['rekognition.enabled']
      binding.pry
      Photo::RecognizeLabelsJob.perform_later(photo)
    end
    BaseFile::GeocodeJob.perform_later(photo)
  end

  # not used
  private

  def set_top_colors
    self.top_colors = begin
                         r = `convert #{file.path} -posterize 5 -define histogram:unique-colors=true -colorspace HSL -format %c histogram:info:- | sort -n -r | head`
                         r.split("\n").map { |i|
                           Hash[
                             [:h, :s, :l].zip(i[/\(([^\)]*)\)/, 1].strip.split(/[, ]+/).map(&:to_i))
                           ]
                         }
                       end
  end
end
