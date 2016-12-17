require_relative 'exceptions'
require 'json'
require 'tumblr_client'

module Slmlrd
  # Wrapper for Tumbler api
  class Tumblr
    def initialize(config)
      ::Tumblr.configure do |c|
        c.consumer_key = config['consumer_key']
        c.consumer_secret = config['consumer_secret']
        c.oauth_token = config['oauth_token']
        c.oauth_token_secret = config['oauth_token_secret']
      end
      @client = ::Tumblr::Client.new
      raise Exceptions::LoginError if @client.info['status'] == 401
    end

    def info
      @client.info
    end

    def get_posts(blog)
      @client.posts(blog)['posts']
    end

    def get_text_posts_with_title(blog, title)
      get_posts(blog).select do |k|
        k['type'] == 'text' && k['title'] == title
      end
    end

    def get_photo_posts_with_caption(blog, caption)
      get_posts(blog).select do |k|
        k['type'] == 'photo' && k['summary'] == caption
      end
    end

    def create_text_post(blog, title, body, tags)
      @client.create_post(
        :text,
        blog,
        title: title,
        body: body,
        tags: tags
      )
    end

    def create_photo_post(blog, caption, source, link, tags)
      @client.create_post(
        :photo,
        blog,
        caption: caption,
        source: source,
        link: link,
        tags: tags
      )
    end

    def delete_post(blog, id)
      @client.delete(blog, id)
    end

    def followers(blog)
      @client.followers(blog)
    end

    def dashboard(user)
      @client.dashboard
    end

    def like(post_id, reblog_key)
      @client.like(post_id, reblog_key)
    end
  end
end
