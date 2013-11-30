# cap email notifier
load "config/cap_notify.rb"

set :application, "ozbapp"

server "188.64.45.50", :web, :app, :db, :primary => true

set :scm, "git"
set :repository, "https://github.com/Avenel/FirstApp.git"
set :branch, "master"

set :user, "ozbapp"
set :deploy_to, "/home/#{user}/apps/#{application}"
set :deploy_via, :remote_cache
set :use_sudo, false
set :host, "ozbapp.mooo.com"
set :stage, "ozbapp.mooo.com"

require 'net/ssh/proxy/socks5'

# Setup email notification
set :notify_emails, ["TKienle@t-online.de", "frank.schaefer@hs-karlsruhe.de", "stefan.welte@stud.uni-karlsruhe.de", "matthias.weidemann@gmail.com", "mail@thomaseger.de", "m.tsarev@gmail.com"]

namespace :deploy do

	desc "Tell Passenger to restart the app."
	task :restart do
		run "mkdir #{current_path}/ozbapp/tmp"
		run "cat > #{current_path}/ozbapp/tmp/restart.txt"
		run "touch #{current_path}/ozbapp/tmp/restart.txt"
	end

	desc "Renew SymLink"
	task :renew_symlink do
		run "rm /home/ozbapp/ozbapp"
		run "ln -s /home/ozbapp/apps/ozbapp/current/ozbapp /home/ozbapp/ozbapp"
	end

	desc "Renew create_tables.txt"
	task :renew_create_tables do
		run "rm /home/ozbapp/create_tables.txt"
		run "cp -f /home/ozbapp/apps/ozbapp/current/tools/create_tables.txt /home/ozbapp/create_tables.txt"
	end

	# Create task to send a notification
	desc "Send email notification"
	task :send_notification do
		Notifier.deploy_notification(self).deliver 
	end

end

namespace :bundle do

  desc "run bundle install and ensure all gem requirements are met"
  task :install do
    run "cd #{current_path} && bundle install  --without=test --no-update-sources"
  end

end

before "deploy:restart", "bundle:install"

after 'deploy:update_code', 'deploy:renew_symlink'
after :deploy, 'deploy:renew_create_tables'
after :deploy, 'deploy:send_notification'
