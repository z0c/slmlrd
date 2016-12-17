require_relative '../lib/slmlrd/bitly'
require_relative '../lib/slmlrd/config'
require 'test/unit'

module Slmlrd
  # Test cases for Bitly
  class TestBitly < Test::Unit::TestCase
    class << self
      def create_sut
        config = Config.new
        ::Slmlrd::Bitly.new(config.data['bitly']['auth'])
      end
    end

    def test_shorten_google
      sut = TestBitly.create_sut
      url = 'http://www.google.com'
      actual = sut.shorten(url)
      assert_not_equal '', actual.short_url
    end
  end
end
