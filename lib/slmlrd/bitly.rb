require 'bitly'

module Slmlrd
  # Bitly wrapper
  class Bitly
    def initialize(config)
      @client = ::Bitly.new(config['username'], config['api_key'])
    end

    def shorten(url)
      @client.shorten(url)
    end
  end
end
