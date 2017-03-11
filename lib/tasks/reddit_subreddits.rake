require_relative '../slmlrd/config'
require_relative '../slmlrd/reddit'
require_relative '../slmlrd/splash'

include Slmlrd

namespace :slmlrd do
  desc 'get subreddits from a listing page'
  task :reddit_subreddits, [:url] do |_t, args|
    Splash.new.do_it

    puts 'Initializing...'
    config = Config.new
    reddit = Reddit.new

    puts 'Reddit: Get subreddits...'
    posts = reddit.get_subreddits(args[:url])

    posts.each do |subreddit|
      puts subreddit unless config.data['profiles'].key?(subreddit) 
    end
  end
end
