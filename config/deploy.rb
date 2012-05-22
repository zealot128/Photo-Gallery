require 'bundler/capistrano'
require "rvm/capistrano"                  # Load RVM's capistrano plugin.
require 'capistrano_colors'
load "deploy/assets"
set :scm, :git
set :repository, "git://github.com/zealot128/AutoShare-Gallery.git"
set :local_repository, "file://."

set :application, "Simple Gallery"
set :user, "stefan"
set :deploy_to, "/apps/pics/prod"
set :use_sudo, false
# https://github.com/capistrano/capistrano/issues/79
set :normalize_asset_timestamps, false
set :git_enable_submodules, 1
set :git_shallow_clone, 1
deployment_type = :thin




role :web, "localhost"                          # Your HTTP server, Apache/etc
role :app, "localhost"                          # This may be the same as your `Web` server
role :db,  "localhost", :primary => true # This is where Rails migrations will run
#
#

set :rails_env, :production


case deployment_type
when :unicorn
  set :unicorn_binary, "bundle exec unicorn"
  set :unicorn_config, "#{current_path}/config/unicorn.rb"
  set :unicorn_pid, "#{current_path}/tmp/pids/unicorn.pid"

  namespace :deploy do
    task :start, :roles => :app, :except => { :no_release => true } do
      run "cd #{current_path} && #{try_sudo} #{unicorn_binary} -c #{unicorn_config} -E #{rails_env} -D"
    end
    task :stop, :roles => :app, :except => { :no_release => true }, on_error: :continue  do
      run "#{try_sudo} kill `cat #{unicorn_pid}`"
    end
    task :graceful_stop, :roles => :app, :except => { :no_release => true } do
      run "#{try_sudo} kill -s QUIT `cat #{unicorn_pid}`"
    end
    task :reload, :roles => :app, :except => { :no_release => true } do
      run "#{try_sudo} kill -s USR2 `cat #{unicorn_pid}`"
    end
    task :restart, :roles => :app, :except => { :no_release => true } do
      stop
      start
    end
  end
when :thin
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
  after 'deploy', "thin:restart"
when :passenger
  namespace :deploy do
    task :start do ; end
    task :stop do ; end
    task :restart, :roles => :app, :except => { :no_release => true } do
      run "#{try_sudo} touch #{File.join(current_path,'tmp','restart.txt')}"
    end
  end
end
#namespace :deploy do
#namespace :assets do
#task :precompile, on_error: :continue do
#run "cp -r #{release_path} #{release_path}/../bblarg"
#end
#end
#end




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
  run "ln -nfs #{shared_path}/photos #{release_path}/public/photos"
end
task :copy_database_yml do
  #run "cp -f #{shared_path}/database.yml #{release_path}/config/database.yml"
end
after "deploy:update_code", :symlink_db
before "deploy:migrate", :copy_database_yml
after 'deploy:update_code', 'deploy:migrate'


#  Paperclip Attachments neu bauen, falls welche fehlen
namespace :deploy do
  desc "build missing paperclip styles"
  task :build_missing_paperclip_styles, :roles => :app do
    run "cd #{release_path}; RAILS_ENV=production bundle exec rake paperclip:refresh:missing_styles"
  end
end
after "deploy:update_code", "deploy:build_missing_paperclip_styles"


