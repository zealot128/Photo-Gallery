class BaseFile::MoveDayJob < ApplicationJob
  queue_as :default

  def perform(base_file, old_day, new_day)
    @base_file = base_file

    if old_day == new_day
      Day::UpdateJob.perform_later(new_day)
      return
    end

    @old_day = old_day
    @new_day = new_day

    if old_day
      new = base_file.shot_at
      @old_str = old_day.date.strftime("%Y-%m-%d")
      @new_str = new.strftime("%Y-%m-%d")
      if @old_str != @new_str
        ([[:original, base_file.file]] + base_file.file.versions.to_a).each do |_key, version|
          move_version(version)
        end
      end
    end

    Day::UpdateJob.perform_later(new_day)
    Day::UpdateJob.perform_later(old_day) if old_day
  end

  attr_reader :old_str, :new_str, :old_day, :new_day

  def move_version(version)
    # rubocop:disable Lint/RedundantStringCoercion
    from = version.path.gsub(new_str, old_str).gsub(%r{/#{new_day.year.to_s}/}, "/#{old_day.year.to_s}/")
    to = version.path.gsub(old_str, new_str).gsub(%r{/#{old_day.year.to_s}/}, "/#{new_day.year.to_s}/")
    Rails.logger.info "[photo] Moving #{from} -> #{to}"
    Rails.logger.info "  #{from} exists? -> #{File.exist?(from)}"
    Rails.logger.info "  #{to}   exists? -> #{File.exist?(to)}"

    case version.file.class.to_s
    when 'CarrierWave::Storage::Fog::File'
      @base_file.shot_at = old_str
      version.cache!
      @base_file.shot_at = new_str
      version.store!
    else
      version.cache!
      version.store!
      if File.exist?(from)
        File.unlink(from)
      end
    end
  end
end
