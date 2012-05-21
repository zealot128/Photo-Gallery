worker_processes 4
preload_app true
timeout 30
listen 9001

after_fork do |server, worker|
    ActiveRecord::Base.establish_connection
end


