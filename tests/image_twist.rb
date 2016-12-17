require_relative '../lib/slmlrd/config'
require_relative '../lib/slmlrd/exceptions'
require_relative '../lib/slmlrd/image_twist'
require 'test/unit'

module Slmlrd
  # Test cases for ImageTwist
  class TestImageTwist < Test::Unit::TestCase
    class << self
      def create_sut
        config = Config.new
        ImageTwist.new(config.data['image_twist']['auth'])
      end

      def startup
        sut = create_sut
        %w(
          test_upload_urls_to_folder
          test_get_urls_in_folder
          test_delete_folder
        ).each do |folder|
          sut.create_folder(folder, nil) if sut.get_folder(folder).nil?
        end
      end

      def shutdown
        sut = create_sut
        %w(
          test_upload_urls_to_folder
          test_get_urls_in_folder
          test_create_folder
          test_delete_folder
        ).each do |folder|
          loop do
            folder = sut.get_folder(folder)
            break if folder.nil?
            sut.delete_folder(folder['id'])
          end
        end
      end
    end

    def test_login_is_successful
      sut = TestImageTwist.create_sut
      sut.login
      assert_equal(true, sut.logged_in?)
    end

    def test_login_with_wrong_credentials_throws_exception
      sut = ImageTwist.new('username' => 'abc', 'password' => '123')
      assert_raise(Exceptions::LoginError) { sut.login }
    end

    def test_folders
      sut = TestImageTwist.create_sut

      folders = sut.folders

      assert_kind_of Array, folders
      assert_operator(folders.count, :>, 0)
      assert_kind_of Hash, folders.first
      assert_match 'http://', folders.first['href']
    end

    def test_create_folder
      sut = TestImageTwist.create_sut
      assert_nothing_raised { sut.create_folder('test_create_folder', nil) }
    end

    def test_upload_urls_to_folder
      sut = TestImageTwist.create_sut
      config = Config.new
      folder_id = sut.get_folder('test_upload_urls_to_folder')['id']

      assert_nothing_raised do
        sut.upload_urls_to_folder(
          folder_id,
          ['https://blog.xenproject.org/wp-content/uploads/2014/10/Testing.jpg'],
          config.data['image_twist']['domain']
        )
      end
    end

    def test_get_urls_in_folder
      sut = TestImageTwist.create_sut
      list = []
      domain = 'http://picshick.com'
      list.push('https://blog.xenproject.org/wp-content/uploads/2014/10/Testing.jpg')
      folder_id = sut.get_folder('test_get_urls_in_folder')['id']
      sut.upload_urls_to_folder(folder_id, list, domain)

      urls = sut.get_urls_in_folder(folder_id, domain)

      assert_kind_of Array, urls
      assert_operator(urls.count, :==, 1)
      assert_match(Regexp.new(Regexp.quote(domain)), urls[0])
    end

    def test_delete_folder
      sut = TestImageTwist.create_sut
      folder_id = sut.get_folder('test_delete_folder')['id']

      assert_nothing_raised { sut.delete_folder(folder_id) }
    end

    def test_session_id
      sut = TestImageTwist.create_sut
      session_id = sut.session_id
      assert_not_equal '', session_id
    end
  end
end
