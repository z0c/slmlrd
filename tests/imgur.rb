require_relative '../lib/slmlrd/exceptions'
require_relative '../lib/slmlrd/imgur'
require 'test/unit'

module Slmlrd
  # Test cases for Imgur
  class TestImgur < Test::Unit::TestCase
    def test_get_images_from_gallery_returns_images_array
      sut = Imgur.new

      images = sut.get_images_from_gallery(URI('http://imgur.com/gallery/NM8qy'))

      assert_kind_of Array, images
      assert_operator(images.count, :==, 10)
    end

    def test_get_images_items_start_with_protocol
      sut = Imgur.new
      images = sut.get_images_from_gallery(URI('http://imgur.com/gallery/NM8qy'))
      images.each do |image|
        assert_match %r{http:\/\/}, image
      end
    end
  end
end
