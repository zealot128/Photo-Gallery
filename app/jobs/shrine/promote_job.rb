class Shrine::PromoteJob < ApplicationJob
  def perform(attacher_class, record, name, file_data)
    attacher_class = Object.const_get(attacher_class)

    attacher = attacher_class.retrieve(model: record, name: name.to_sym, file: file_data)
    attacher.file.open do
      attacher.refresh_metadata!(background: true) # extract metadata
      attacher.create_derivatives
    end
    attacher.atomic_promote
    record.enqueue_jobs

  rescue Shrine::AttachmentChanged, ActiveRecord::RecordNotFound
    # attachment has changed or record has been deleted, nothing to do
  end
end
