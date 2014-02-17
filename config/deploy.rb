lock '3.1.0'

set :application, 'wordfun.ca'
set :repo_url,  "https://github.com/pbevin/wordfun.git"
set :deploy_to, '/home/www/wordfun'
set :scm, :git

namespace :deploy do

  desc 'Restart application'
  task :restart do
    invoke "deploy:assets:precompile"
    on roles(:app), in: :sequence, wait: 5 do
      execute :mkdir, release_path.join('tmp')
      execute :touch, release_path.join('tmp/restart.txt')
    end
  end

  after :publishing, :restart

  after :restart, :clear_cache do
    on roles(:web), in: :groups, limit: 3, wait: 10 do
      # Here we can do anything such as:
      # within release_path do
      #   execute :rake, 'cache:clear'
      # end
    end
  end

  namespace :assets do
    task :precompile do
      on roles(:app) do
        within release_path do
          with rack_env: (fetch("stage") || "production") do
            execute :rake, "assets:precompile"
          end
        end
      end
    end
  end

end
