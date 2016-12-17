require_relative '../lib/slmlrd/exceptions'
require_relative '../lib/slmlrd/reddit'
require 'test/unit'

module Slmlrd
  # Tests cases for Reddit
  class TestReddit < Test::Unit::TestCase
    def test_get_posts_returns_posts
      sut = Reddit.new

      posts = sut.get_posts('ruby', %r{https://www\.reddit\.com/})

      assert_kind_of Hash, posts
      assert_operator(posts.count, :>, 0)
    end
  end
end
