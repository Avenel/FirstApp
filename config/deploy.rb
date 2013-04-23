set :application, "ozbapp"

server "188.64.45.50", :web, :app, :db, :primary => true

set :scm, "git"
set :repository, "https://github.com/Avenel/FirstApp.git"
set :branch, "master"

set :user, "ozbapp"
set :deploy_to, "/home/#{user}/apps/#{application}"
set :deploy_via, :remote_cache
set :use_sudo, false

ssh_options[:forward_agent] = true

namespace :deploy do

	desc "Tell Passenger to restart the app."
	task :restart do
		run "touch #{current_path}/ozbapp/tmp/restart.txt"
	end

	desc "Renew SymLink"
	task :renew_symlink do
		run "rm -rf /home/ozbapp/ozbapp"
		run "ln -s /home/ozbapp/apps/ozbapp/current/ozbapp /home/ozbapp/ozbapp"
end

end

after 'deploy:update_code', 'deploy:renew_symlink'
