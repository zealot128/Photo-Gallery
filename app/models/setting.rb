# RailsSettings Model
class Setting < RailsSettings::Base
  source Rails.root.join("config/app.yml")
  namespace Rails.env


  def self.definitions
    ts = I18n.t('settings')
    def_descend(ts, [])
  end

  def self.def_descend(group, full_key)
    if group[:type]
      group[:key] = full_key.join(".")
      group
    else
      group.flat_map do |key, body|
        def_descend(body, full_key + [ key ])
      end
    end
  end
end
