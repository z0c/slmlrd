require 'base64'
require 'json'

module Slmlrd
  # Configuration helper
  class Config
    class << self
      def config_path
        File.expand_path(
          File.join(File.dirname(__FILE__), '../../config.json')
        )
      end

      def push
        file = File.read(config_path)
        encoded = Base64.encode64(file)
        raise "Config > #{MAX_BYTES}b" if encoded.bytesize > MAX_BYTES
        `heroku config:set SLMLRD='#{encoded}'`
      end

      def pull
        encoded = `heroku config:get SLMLRD`
        decoded = Base64.decode64(encoded)
        open(config_path, 'w') do |f|
          f.puts decoded
        end
        puts "Updated #{config_path}"
      end
    end

    attr_accessor :data
    MAX_BYTES = 32_000

    def initialize
      if File.file?(Config.config_path)
        file = File.read(Config.config_path)
        @data = JSON.parse(file)
      else
        @data = read_from_environment
      end
    end

    private

    def read_from_environment
      encoded = ENV['SLMLRD']
      decoded = Base64.decode64(encoded)
      JSON.parse(decoded)
    end
  end
end
