class Admin::SettingsController < ApplicationController
  before_action :admin_required

  def index
    @settings = Setting.get_all
  end

  def update
    definitions = Setting.definitions
    tainted = false
    params[:setting].each do |key, value|
      df = definitions.find { |i| i[:key] == key }
      casted_value = case df[:type]
                     when 'integer' then value.to_f
                     when 'boolean'
                       value == '1'
                     else
                       value
                     end
      if Setting[key] != casted_value
        Setting[key] = casted_value
        tainted = true
      end
    end
    if tainted && Rails.env.production?
      FileUtils.touch('tmp/restart.txt')
    end
    redirect_to admin_settings_path, notice: (tainted ? "Update erfolgreich. App-Neustart veranlasst." : "Kein Update erfolgt.")
  end
end
