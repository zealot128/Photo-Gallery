set :output, "#{Dir.pwd}/log/cron.log"
job_type :runner, "cd :path && bin/rails runner -e :environment ':task' :output"


every 15.minutes do
  runner 'Cronjobs.rekognize'
end
