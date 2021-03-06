# == Schema Information
#
# Table name: settings
#
#  id         :integer          not null, primary key
#  var        :string           not null
#  value      :text
#  thing_id   :integer
#  thing_type :string(30)
#  created_at :datetime
#  updated_at :datetime
#

# RailsSettings Model
class Setting < RailsSettings::Base
  source Rails.root.join("config/app.yml")
  namespace Rails.env

  def self.storage_for(type)
    if type.to_sym == :large
      (ENV['STORE_LARGE'] || Setting['storage.large']).to_sym
    elsif type.to_sym == :original
      (ENV['STORE_ORIGINAL'] || Setting['storage.original']).to_sym
    else
      (ENV['STORE_DEFAULT'] || Setting['storage.default']).to_sym
    end
  end

  def self.image_processing
    Setting.vips_installed? ? ImageProcessing::Vips : ImageProcessing::MiniMagick
  end

  def self.definitions
    ts = I18n.t('settings')
    def_descend(ts, [])
  end

  def self.tesseract_installed?
    `which tesseract`.size.>(0)
  end

  def self.vips_installed?
    `which vips`.size.>(0)
  end

  def self.ffmpeg_installed?
    `which ffmpeg`.size.>(0)
  end

  def self.def_descend(group, full_key)
    if group[:type]
      group[:key] = full_key.join(".")
      group
    else
      group.flat_map do |key, body|
        def_descend(body, full_key + [key])
      end
    end
  end
end
