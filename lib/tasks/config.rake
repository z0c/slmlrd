require_relative '../slmlrd/config'
require_relative '../slmlrd/splash'
include Slmlrd

namespace 'slmlrd:config' do
  desc 'Push up local config'
  task :push do
    Splash.new.do_it
    Config.push
  end

  desc 'Pull down remote config'
  task :pull do
    Splash.new.do_it
    Config.pull
  end
end
