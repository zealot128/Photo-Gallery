

require 'bundler/capistrano'
$:.unshift(File.expand_path('./lib', ENV['rvm_path'])) # Add RVM's lib directory to the load path.
require "rvm/capistrano"                  # Load RVM's capistrano plugin.
require 'capistrano_colors'
load "deploy/assets"
set :scm, :git
set :repository, "git://github.com/zealot128/AutoShare-Gallery.git"
set :local_repository, "file://."

set :application, "Empfehlungsbund.de"
set :user, "root"
set :deploy_to, "/var/www/vhosts/stefanwienert.net/sub/pics"
set :use_sudo, false
# https://github.com/capistrano/capistrano/issues/79
set :normalize_asset_timestamps, false
 role :web, "localhost"                          # Your HTTP server, Apache/etc
 role :app, "localhost"                          # This may be the same as your `Web` server
 role :db,  "localhost", :primary => true # This is where Rails migrations will run
#
 #
namespace :thin do
  desc "Start the Thin processes"
  task :start do
    run  <<-CMD
      cd #{current_path}; bundle exec thin start -C config/thin.yml
    CMD
  end

  desc "Stop the Thin processes"
  task :stop do
    run <<-CMD
      cd #{current_path}; bundle exec thin stop -C config/thin.yml
    CMD
  end

  desc "Restart the Thin processes"
  task :restart do
    run <<-CMD
      cd #{current_path}; bundle exec thin restart -C config/thin.yml
    CMD
  end

end

namespace :deploy do
  namespace :assets do
    task :precompile, :roles => :web, :except => { :no_release => true } do
      from = source.next_revision(current_revision)
      if capture("cd #{latest_release} && #{source.local.log(from)} vendor/assets/ app/assets/ config/application.rb | wc -l").to_i > 0
        run %Q{cd #{latest_release} && #{rake} RAILS_ENV=#{rails_env} #{asset_env} assets:precompile}
      else
        logger.info "Skipping asset pre-compilation because there were no asset changes"
      end
    end
  end
end


task :setup, :roles => [:app, :db, :web] do
  run <<-CMD
    mkdir -p -m 775 #{release_path} #{shared_path}/system #{shared_path}/db #{shared_path}/photos &&
    mkdir -p -m 777 #{shared_path}/log &&
    touch #{shared_path}/db/production.sqlite3
  CMD
end
after "deploy:setup", "setup"
task :symlink_db do
  run "ln -nfs #{shared_path}/db/production.sqlite3 #{release_path}/db/production.sqlite3"
  run "ln -nfs #{shared_path}/public/photos #{release_path}/photos"

end
after "deploy:update_code", :symlink_db
after 'deploy:update_code', 'deploy:migrate'


