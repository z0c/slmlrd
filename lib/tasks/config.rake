require_relative '../slmlrd/config'
require_relative '../slmlrd/splash'
include Slmlrd

namespace 'slmlrd:config' do
  desc 'Push up local config'
  task :push, [:app] do |t, args|
    Splash.new.do_it
    Config.push args[:app]
  end

  desc 'Pull down remote config'
  task :pull, [:app] do |t, args|
    Splash.new.do_it
    Config.pull args[:app]
  end
end
