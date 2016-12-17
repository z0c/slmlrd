require_relative 'exceptions'
require 'json'
require 'rest-client'

module Slmlrd
  # Reddit helper
  class Reddit
    HOME_URL = 'https://www.reddit.com/r/'.freeze
    USER_AGENT = 'Mozilla/5.0 (compatible; MSIE 9.0; Windows NT 6.0; Trident/5.0; Trident/5.0)'.freeze

    def get_posts(subreddit, url_filter)
      json = fetch_content_json(subreddit)
      filtered = filter_by_url(json, url_filter)
      sorted = sort_by_score(filtered)
      build_hash(sorted)
    end

    private

    def fetch_content_json(subreddit)
      resp = RestClient.get(
        HOME_URL + subreddit + '.json',
        user_agent: USER_AGENT
      )
      raise Exceptions::ResponseCodeError, resp.code unless resp.code == 200
      JSON.parse(resp.body)
    end

    def filter_by_url(json, url_filter)
      json['data']['children'].select do |c|
        url_filter.match(c['data']['url'])
      end
    end

    def sort_by_score(json)
      json.sort_by do |c|
        -c['data']['score']
      end
    end

    def build_hash(json)
      store = {}
      json.each do |child|
        store[child['data']['url'].rpartition('/').last] = {
          'title' => child['data']['title'],
          'url' => child['data']['url']
        }
      end
      store
    end
  end
end
