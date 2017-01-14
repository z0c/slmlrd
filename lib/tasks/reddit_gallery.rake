require_relative '../slmlrd/config'
require_relative '../slmlrd/image_twist'
require_relative '../slmlrd/imgur'
require_relative '../slmlrd/normalizer'
require_relative '../slmlrd/reddit'
require_relative '../slmlrd/splash'
require_relative '../slmlrd/tumblr'

include Slmlrd

namespace :slmlrd do
  desc 'reddit.gallery -> tumblr'
  task :reddit_gallery, [:profile] do |_t, args|
    Splash.new.do_it

    puts 'Initializing...'
    config = Config.new
    image_twist = ImageTwist.new(config.data['image_twist']['auth'])
    imgur = Imgur.new
    normalizer = Normalizer.new
    reddit = Reddit.new
    time = Time.new
    tumblr = Slmlrd::Tumblr.new(config.data['tumblr']['auth'])

    puts 'Profile: Get...'
    profile = config.data['profiles'][args[:profile]]
    puts profile

    puts 'Reddit: Get posts...'
    posts = reddit.get_posts(
      profile['reddit']['subreddit'],
      Regexp.new(Regexp.quote(profile['reddit']['url_filter'])),
      0
    )
    posts.each { |post| puts "  #{post}" }

    puts 'ImageTwist: Get folders...'
    folders = image_twist.folders

    puts 'Reddit: Remove already imported posts...'
    folders.each do |folder|
      folder_name = folder['name'].split('_').last
      if posts.key?(folder_name)
        puts "  removing #{folder_name}"
        posts.delete(folder_name)
      end
    end

    puts 'Reddit: Keep the first post...'
    if posts.count.zero?
      puts 'Nothing new to import, exiting.'
      next
    end
    post = posts.first
    post_key = post.first.to_s
    post = post[1]
    puts "  keeping #{post_key}: #{post}"

    puts 'ImageTwist: Create folder...'
    folder_name = "#{time.strftime('%Y%m%d')}_imgur_a_#{post_key}"
    image_twist.create_folder(folder_name, config.data['image_twist']['domain'])
    folder = image_twist.get_folder(folder_name)
    puts "  created folder #{folder_name} with id #{folder['id']}"

    puts 'Imgur: Get images...'
    images = imgur.get_images_from_gallery(URI(post['url']))
    images.each { |image| puts "  #{image}" }

    puts 'Normalizer: Normalizing title'
    caption = normalizer.normalize_title(post['title'])
    puts "  new title: #{caption}"

    puts 'Tumblr: Creating text post'
    tags = profile['tumblr']['tags']
    source = images[0]
    puts "  Blog: #{config.data['tumblr']['blog']}"
    puts "  Caption: '#{caption}'"
    puts "  Tags: '#{tags}'"
    puts "  Source: '#{source}'"
    tumblr.create_photo_post(
      config.data['tumblr']['blog'],
      caption,
      source,
      '',
      tags
    )
  end
end
