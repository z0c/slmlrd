require_relative 'exceptions'
require 'json'
require 'nokogiri'
require 'rest-client'

module Slmlrd
  # Reddit helper
  class Reddit
    HOME_URL = 'https://www.reddit.com/r/'.freeze
    USER_AGENT = 'Mozilla/5.0 (compatible; MSIE 9.0; Windows NT 6.0; Trident/5.0; Trident/5.0)'.freeze

    def get_posts(subreddit, url_filter, min_score)
      json = fetch_content_json(subreddit)
      filtered = filter_by_url(json, url_filter)
      enough_score = filter_by_score(filtered, min_score)
      sorted = sort_by_score(enough_score)
      build_hash(sorted)
    end

    def get_subreddits url
      resp = RestClient.get(
        url,
        user_agent: USER_AGENT
      )
      raise Exceptions::ResponseCodeError, resp.code unless resp.code == 200
      subreddits = []
      Nokogiri::HTML(resp.body).css('div.md.wiki').map.each do |c|
        c.css('a').map do |n|
          sr = n.text.strip.downcase
          subreddits.push(sr.split('/')[2]) if sr.start_with?('/r/')
        end
      end
      subreddits
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
      return json if url_filter.nil?
      json['data']['children'].select do |c|
        url_filter.match(c['data']['url'])
      end
    end

    def filter_by_score(json, min_score)
      return json if min_score.nil?
      json.select do |c|
        c['data']['score'] >= min_score
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
        id = child['data']['url']
        id = id.rpartition('/').last if id.include?('/')
        id = id.rpartition('.').first if id.include?('.')
        store[id] = {
          'score' => child['data']['score'],
          'title' => child['data']['title'],
          'url' => child['data']['url']
        }
      end
      store
    end
  end
end
