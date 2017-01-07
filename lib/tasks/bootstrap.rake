require_relative '../slmlrd/splash'
include Slmlrd

namespace 'slmlrd:bootstrap' do
  desc 'Bootstraps Heroku'
  task :heroku, [:app] do |_t, args|
    Splash.new.do_it
    `heroku addons:create scheduler:standard --app #{args[:app]}`
  end
end
