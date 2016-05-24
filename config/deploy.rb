server '107.170.47.11', port: 22, roles: [:web, :app, :db], primary: true

set :repo_url,        'git@github.com:jhubbardsf/twitter-backend.git'
set :application,     'NurelmBack'
set :user,            'deploy'
set :puma_threads,    [4, 16]
set :puma_workers,    0

# Don't change these unless you know what you're doing
set :pty,             true
set :use_sudo,        false
set :stage,           :production
set :deploy_via,      :remote_cache
set :deploy_to,       "/home/#{fetch(:user)}/apps/#{fetch(:application)}"
set :puma_bind,       "unix://#{shared_path}/tmp/sockets/#{fetch(:application)}-puma.sock"
set :puma_state,      "#{shared_path}/tmp/pids/puma.state"
set :puma_pid,        "#{shared_path}/tmp/pids/puma.pid"
set :puma_access_log, "#{release_path}/log/puma.error.log"
set :puma_error_log,  "#{release_path}/log/puma.access.log"
set :ssh_options,     { forward_agent: true, user: fetch(:user), keys: %w(~/.ssh/id_rsa.pub) }
set :puma_preload_app, true
set :puma_worker_timeout, nil
set :puma_init_active_record, true  # Change to false when not using ActiveRecord

set :default_env, {
    'PATH' => '/home/deploy/.rvm/gems/ruby-2.3.1/bin:/home/deploy/.rvm/bin:$PATH',
    'RUBY_VERSION' => 'ruby-2.3.1',
    'GEM_HOME'     => '/home/USER/.rvm/gems/ruby-2.3.1',
    'GEM_PATH'     => '/home/USER/.rvm/gems/ruby-2.3.1',
    'BUNDLE_PATH'  => '/home/USER/.rvm/gems/ruby-2.3.1'
}

## Defaults:
# set :scm,           :git
# set :branch,        :master
# set :format,        :pretty
# set :log_level,     :debug
# set :keep_releases, 5

## Linked Files & Directories (Default None):
# set :linked_files, %w{config/secrets.yml .env}
# set :linked_dirs,  %w{bin log tmp/pids tmp/cache tmp/sockets vendor/bundle public/system}

namespace :puma do
  desc 'Create Directories for Puma Pids and Socket'
  task :make_dirs do
    on roles(:app) do
      execute "mkdir #{shared_path}/tmp/sockets -p"
      execute "mkdir #{shared_path}/tmp/pids -p"
    end
  end

  before :start, :make_dirs
end

# Default value for keep_releases is 5
set :keep_releases, 5

namespace :deploy do
  task :install_dependencies do
    on roles(:web), in: :sequence, wait: 5 do
      within release_path do
        execute :bundle, "--without development test"
      end
    end
  end
  after :published, :install_dependencies
end


# ps aux | grep puma    # Get puma pid
# kill -s SIGUSR2 pid   # Restart puma
# kill -s SIGTERM pid   # Stop puma