require_relative '../slmlrd/config'
require_relative '../slmlrd/reddit'
require_relative '../slmlrd/splash'

include Slmlrd

namespace :slmlrd do
  desc 'view posts on reddit'
  task :view_reddit_posts, [:profile] do |_t, args|
    Splash.new.do_it

    puts 'Initializing...'
    config = Config.new
    reddit = Reddit.new

    puts 'Profile: Get...'
    profile = config.data['profiles'][args[:profile]]
    puts profile

    puts 'Reddit: Get posts...'
    posts = reddit.get_posts(
      profile['reddit']['subreddit'],
      /^http/
    )
    posts.each { |post| puts "  #{post}" }
  end
end
