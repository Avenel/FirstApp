set :application, "ozbapp"

server "188.64.45.50", :web, :app, :db, :primary => true

set :scm, "git"
set :repository, "git://github.com/Avenel/FirstApp.git"
set :branch, "master"

set :user, "ozbapp"
set :deploy_to, "/home/#{user}/apps/#{application}"
set :deploy_via, :remote_cache
set :use_sudo, false

ssh_options[:forward_agent] = true

namespace :deploy do

  desc "Tell Passenger to restart the app."
  task :restart do
    run "touch #{current_path}/tmp/restart.txt"
  end

end