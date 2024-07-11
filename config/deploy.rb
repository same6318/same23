# config valid for current version and patch releases of Capistrano
lock "~> 3.19.1" #capistranoのバージョン

#capistranoの設定
set :application, "blog_app" #ec2に置かれるアプリケーション名
set :repo_url, "https://github.com/same6318/same23.git" #必ずhttps
set :bundle_without, %w{test}.join(':') #gemのインストールをする設定（テスト環境以外も）

set :rbenv_version, '3.3.0'

append :linked_files, 'config/secrets.yml'
set :linked_dirs, %w{log tmp/pids tmp/cache tmp/sockets public/uploads} #appndとの差？
set :linked_files, %w{config/secrets.yml .env} #s3のアクセスキーがある環境変数を読み込むためのリンクを作る
set :keep_releases, 5 #releasesディレクトリ内で保持するバージョンの個数を設定
set :log_level, :info #エラーのログレベルを指定
set :branch, 'main'

after "deploy:published", "deploy:seed" #デプロイ時にseedデータを投入する
after "deploy:finished", "deploy:restart" #何でリスタート？=アプリに機能を追加した後にリスタートしないと変更内容が反映されないから

namespace :deploy do
  desc "Run seed"
  task :seed do
    on roles(:db) do
      with rails_env: fetch(:rails_env) do
        within current_path do
          execute :bundle, :exec, :rake, "db:seed"
        end
      end
    end
  end
  desc "Restart application"
  task :restart do
    invoke "unicorn:restart"
  end
end

# Default branch is :master
# ask :branch, `git rev-parse --abbrev-ref HEAD`.chomp

# Default deploy_to directory is /var/www/my_app_name
# set :deploy_to, "/var/www/my_app_name"

# Default value for :format is :airbrussh.
# set :format, :airbrussh

# You can configure the Airbrussh format using :format_options.
# These are the defaults.
# set :format_options, command_output: true, log_file: "log/capistrano.log", color: :auto, truncate: :auto

# Default value for :pty is false
# set :pty, true

# Default value for :linked_files is []
# append :linked_files, "config/database.yml", 'config/master.key'

# Default value for linked_dirs is []
# append :linked_dirs, "log", "tmp/pids", "tmp/cache", "tmp/sockets", "public/system", "vendor", "storage"

# Default value for default_env is {}
# set :default_env, { path: "/opt/ruby/bin:$PATH" }

# Default value for local_user is ENV['USER']
# set :local_user, -> { `git config user.name`.chomp }

# Default value for keep_releases is 5
# set :keep_releases, 5

# Uncomment the following to require manually verifying the host key before first deploy.
# set :ssh_options, verify_host_key: :secure
