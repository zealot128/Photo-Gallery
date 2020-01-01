class Shrine::DestroyJob < ApplicationJob
  def perform(attacher_class, record_class, record_id, name, file_data)
    attacher_class = Object.const_get(attacher_class)

    attacher = attacher_class.from_data(data)
    attacher.destroy
  end
end
