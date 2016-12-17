require_relative '../slmlrd/bitly'
require_relative '../slmlrd/config'
require_relative '../slmlrd/image_twist'
require_relative '../slmlrd/imgur'
require_relative '../slmlrd/normalizer'
require_relative '../slmlrd/reddit'
require_relative '../slmlrd/splash'
require_relative '../slmlrd/tumblr'

include Slmlrd

namespace :slmlrd do
  desc 'like the j'
  task :jeremy do
    Splash.new.do_it

    puts 'Initializing...'
    config = Config.new
    bitly = Slmlrd::Bitly.new(config.data['bitly']['auth'])
    image_twist = ImageTwist.new(config.data['image_twist']['auth'])
    imgur = Imgur.new
    normalizer = Normalizer.new
    reddit = Reddit.new
    time = Time.new
    tumblr = Slmlrd::Tumblr.new(config.data['tumblr']['auth'])

    puts 'Reddit: Get posts...'
    posts = reddit.get_posts(
      config.data['reddit']['subreddit'],
      Regexp.new(Regexp.quote(config.data['reddit']['url_filter']))
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

    puts 'ImageTwist: Upload images...'
    puts "  domain: #{config.data['image_twist']['domain']}"
    image_twist.upload_urls_to_folder(
      folder['id'],
      images,
      config.data['image_twist']['domain']
    )

    puts 'Normalizer: Normalizing title'
    caption = normalizer.normalize_title(post['title'])
    puts "  new title: #{caption}"

    puts 'Bitly: Shorten url for folder'
    short_url = bitly.shorten(folder['href']).short_url
    puts "  Short url: #{short_url}"

    puts 'Tumblr: Creating text post'
    tags = config.data['tumblr']['tags']
    source = images[0]
    puts "  Posting '#{caption}' '#{tags}' Source: '#{source}' Link: '#{short_url}"
    tumblr.create_photo_post(
      config.data['tumblr']['blog'],
      caption,
      source,
      short_url,
      tags
    )
  end
end
