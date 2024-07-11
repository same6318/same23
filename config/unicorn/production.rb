worker_processes  2   #起動するワーカー数
 working_directory "/var/www/blog_app/current"    #unicornの起動ディレクトリ
 stderr_path "log/unicorn.stderr.log"    #エラーログの出力先
 stdout_path "log/unicorn.stdout.log"    #標準出力の出力先
 timeout 30    #ワーカープロセスのタイムアウトを設定
 listen "/var/www/blog_app/current/tmp/sockets/unicorn.sock"
 #リクエストを受け取るアドレスやポート、UNIXドメインソケットなどを定義（nginx側の設定でも同じUNIXドメインソケットとなる）
 pid '/var/www/blog_app/current/tmp/pids/unicorn.pid' #unicornのPID（プロセス）の出力先の定義
 preload_app true

before_fork do |server, worker|   #preload_appをtrueに設定するのに推奨らしい。詳細不明
  defined?(ActiveRecord::Base) and ActiveRecord::Base.connection.disconnect!
  old_pid = "#{server.config[:pid]}.oldbin"
  if old_pid != server.pid
    begin
      sig = (worker.nr + 1) >= server.worker_processes ? :QUIT : :TTOU
      Process.kill(sig, File.read(old_pid).to_i)
    rescue Errno::ENOENT, Errno::ESRCH
    end
  end
end

after_fork do |server, worker|    #preload_appをtrueに設定するのに推奨らしい。詳細不明
  defined?(ActiveRecord::Base) and ActiveRecord::Base.establish_connection
end