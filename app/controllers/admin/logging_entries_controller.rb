class Admin::LoggingEntriesController < ApplicationController
  before_action :admin_required

  def index
    @logging_entries = LoggingEntry.order('created_at desc').paginate(page: params[:page])
    if params[:severity] and LoggingEntry.severities.keys.include?(params[:severity])
      @logging_entries = @logging_entries.where(severity: LoggingEntry.severities[params[:severity]])
    end
    if params[:q]
      @logging_entries = @logging_entries.where('message ilike ?', '%' + params[:q] + '%')
    end
  end
end
