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
        attacher = base_file.file_attacher
        old_attacher = attacher.dup
        attacher.set(attacher.upload(attacher.file)) # reupload file
        attacher.set_derivatives(attacher.upload_derivatives(attacher.derivatives)) # reupload derivatives if you have derivatives

        attacher.persist
        old_attacher.destroy_attached
      end
    end

    Day::UpdateJob.perform_later(new_day)
    Day::UpdateJob.perform_later(old_day) if old_day
  end
end
