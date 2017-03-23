require_relative '../slmlrd/config'
require_relative '../slmlrd/splash'
include Slmlrd

desc 'Push up local config'
task :config_push, [:app] do |_t, args|
  Splash.new.do_it
  Config.push args[:app]
end

desc 'Pull down remote config'
task :config_pull, [:app] do |_t, args|
  Splash.new.do_it
  Config.pull args[:app]
end
