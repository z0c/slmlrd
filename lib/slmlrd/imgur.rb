require_relative 'exceptions'
require 'nokogiri'
require 'rest-client'

module Slmlrd
  # Imgur helper
  class Imgur
    def get_images_from_gallery(source_uri)
      resp = RestClient.get(source_uri.to_s)
      raise Exceptions::ResponseCodeError, resp.code unless resp.code == 200
      page = Nokogiri::HTML(resp.body)
      parse_images_in_page(page)
    end

    private

    def parse_images_in_page(page)
      urls = []
      page.css('div[@class="post-image"] a').each do |n|
        url = n['href']
        if url[0..1] == '//'
          urls.push("http:#{url}")
        else
          urls.push(url)
        end
      end
      urls
    end
  end
end
