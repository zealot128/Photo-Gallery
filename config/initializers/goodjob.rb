GoodJob.preserve_job_records = true
GoodJob.on_thread_error = -> (exception) { ExceptionNotifier.notify_exception(exception) if defined?(ExceptionNotifier) }
