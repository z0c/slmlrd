require_relative '../slmlrd/splash'
include Slmlrd

namespace 'slmlrd:bootstrap' do
  desc 'Bootstraps Heroku'
  task :heroku, [:app] do |_t, args|
    Splash.new.do_it
    `heroku apps:create --app #{args[:app]}`
    `heroku addons:create scheduler:standard --app #{args[:app]}`
    Rake::Task['slmlrd:config:push'].invoke(args[:app])

    puts "Login to heroku and select #{args[:app]}"
    puts ' -> Deploy'
    puts '	Deployment method -> Github'
    puts '	Connect to GitHub -> repo-name -> slmlrd'
    puts '	Connect'
    puts '	Automatic deploys -> Enable Automatic Deploys'
    puts ' 	Manual deploy -> Deploy Branch'
    puts ' -> Resources'
    puts '	Free Dynos -> web -> disable'
    puts '	Heroku Scheduler -> Add new job'
    puts '		rake slmlrd:reddit_gallery[profile]'
    puts '		Free, Hourly'
    puts ''
    puts 'Done!'
    puts ''
  end
end
