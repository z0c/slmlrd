require_relative '../slmlrd/config'
require_relative '../slmlrd/splash'
require_relative '../slmlrd/tumblr'

include Slmlrd

namespace :slmlrd do
  desc 'do the like stuff'
  task :tumblr_liker do
    Splash.new.do_it

    puts 'Initializing...'
    config = Config.new
    tumblr = Slmlrd::Tumblr.new(config.data['tumblr']['auth'])

    puts 'Tumblr: Getting the dashboard...'
    min_notes = config.data['tumblr']['like_min_notes']
    max_notes = config.data['tumblr']['like_max_notes']
    tumblr.dashboard['posts'].each do |post|
      next if post['blog_name'] == blog
      next if post['liked']
      next if post['type'] != 'photo'
      next if post['note_count'] < min_notes
      next if post['note_count'] > max_notes
      puts "  liking #{post['post_url']}"
      tumblr.like(post['id'], post['reblog_key'])
    end
  end
end
