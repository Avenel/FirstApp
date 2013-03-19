root = "/home/nazz/apps/ozbapp/current"
working_directory root
pid "#{root}/tmp/pids/unicorn.pid"
stderr_path "#{root}/log/unicorn.log"
stdout_path "#{root}/log/unicorn_err.log"

listen "127.0.0.1:34568"
worker_processes 2
timeout 30
preload_app true