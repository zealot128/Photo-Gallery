worker_processes 4
preload_app true
timeout 30
listen 9001
working_directory "/apps/pics/prod/current"
pid "/apps/pics/prod/current/tmp/pids/unicorn.pid"


GC.respond_to?(:copy_on_write_friendly=) and
  GC.copy_on_write_friendly = true

after_fork do |server, worker|
    ActiveRecord::Base.establish_connection
end


