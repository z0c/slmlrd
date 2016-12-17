require_relative '../lib/slmlrd/config'
require_relative '../lib/slmlrd/exceptions'
require_relative '../lib/slmlrd/tumblr'
require 'test/unit'

module Slmlrd
  # Test cases for Tumblr
  class TestTumblr < Test::Unit::TestCase
    class << self
      CREATE_TEXT_POST_TITLE = 'test_create_text_post'.freeze
      DELETE_TEXT_POST_TITLE = 'test_delete_text_post'.freeze
      CREATE_PHOTO_POST_CAPTION = 'test_create_photo_post'.freeze
      DELETE_PHOTO_POST_CAPTION = 'test_delete_photo_post'.freeze

      def create_sut
        config = Config.new
        Tumblr.new(config.data['tumblr']['auth'])
      end

      def startup
        config = Config.new
        sut = create_sut

        sut.create_text_post(
          config.data['tumblr']['blog'],
          DELETE_TEXT_POST_TITLE,
          '',
          ''
        )

        sut.create_photo_post(
          config.data['tumblr']['blog'],
          DELETE_PHOTO_POST_CAPTION,
          'https://blog.xenproject.org/wp-content/uploads/2014/10/Testing.jpg',
          '',
          ''
        )
      end

      def shutdown
        config = Config.new
        sut = create_sut

        sut.get_text_posts_with_title(
          config.data['tumblr']['blog'],
          CREATE_TEXT_POST_TITLE
        ).each do |post|
          sut.delete_post(config.data['tumblr']['blog'], post['id'])
        end

        sut.get_photo_posts_with_caption(
          config.data['tumblr']['blog'],
          CREATE_PHOTO_POST_CAPTION
        ).each do |post|
          sut.delete_post(config.data['tumblr']['blog'], post['id'])
        end
      end
    end

    def test_login_with_wrong_credentials_throws_exception
      assert_raise(Exceptions::LoginError) do
        Tumblr.new(
          'consumer_key' => '',
          'consumer_secret' => '',
          'oauth_token' => '',
          'oauth_token_secret' => ''
        )
      end
    end

    def test_login
      assert_nothing_raised { TestTumblr.create_sut }
    end

    def test_get_posts
      sut = TestTumblr.create_sut
      posts = sut.get_posts('codingjester.tumblr.com')
      assert_operator(posts.count, :>, 0)
    end

    def test_create_text_post
      sut = TestTumblr.create_sut
      config = Config.new
      title = 'test_create_text_post'
      blog = config.data['tumblr']['blog']

      assert_nothing_raised { sut.create_text_post(blog, title, '', '') }
      assert_not_nil sut.get_text_posts_with_title(blog, title).first['id']
    end

    def test_create_photo_post
      sut = TestTumblr.create_sut
      config = Config.new
      caption = 'test_create_photo_post'
      blog = config.data['tumblr']['blog']
      source = 'https://blog.xenproject.org/wp-content/uploads/2014/10/Testing.jpg'
      link = 'https://www.google.com'

      assert_nothing_raised { sut.create_photo_post(blog, caption, source, link, '') }
      assert_not_nil sut.get_photo_posts_with_caption(blog, caption).first['id']
    end

    def test_delete_text_post
      sut = TestTumblr.create_sut
      config = Config.new
      blog = config.data['tumblr']['blog']
      title = 'test_delete_text_post'
      id = sut.get_text_posts_with_title(blog, title).first['id']

      assert_nothing_raised { sut.delete_post(blog, id) }
      assert_equal 0, sut.get_text_posts_with_title(blog, title).count
    end

    def test_delete_photo_post
      sut = TestTumblr.create_sut
      config = Config.new
      blog = config.data['tumblr']['blog']
      caption = 'test_delete_photo_post'
      id = sut.get_photo_posts_with_caption(blog, caption).first['id']

      assert_nothing_raised { sut.delete_post(blog, id) }
      assert_equal 0, sut.get_photo_posts_with_caption(blog, caption).count
    end
  end
end
