module Released
  module Repos
    class RubyGems
      class Gem
        attr_reader :name
        attr_reader :version

        def initialize(name:, version:)
          @name = name
          @version = version
        end
      end

      # FIXME: use actual base URL
      BASE_URL = 'http://0.0.0.0:9292'.freeze

      def initialize(base_url: BASE_URL, authorization:)
        @base_url = base_url
        @authorization = authorization
      end

      # FIXME: verify that authorization does not end with a newline

      def owned_gems
        url = gems_get_uri

        req = Net::HTTP::Get.new(url)
        req['Authorization'] = @authorization

        res = Net::HTTP.start(url.hostname, url.port, use_ssl: url.scheme == 'https') do |http|
          http.request(req)
        end

        case res
        when Net::HTTPSuccess
          JSON.parse(res.body).map { |e| Gem.new(name: e['name'], version: e['version']) }
        when Net::HTTPUnauthorized
          raise 'Authorization failed'
        else
          raise "Unknown error: #{res.body}"
        end
      end

      def push_gem(filename)
        gem_size = File.size(filename)
        File.open(filename, 'r') do |io|
          url = gems_push_uri

          req = Net::HTTP::Post.new(url)
          req['Authorization'] = @authorization
          req['Content-Length'] = gem_size
          req.body_stream = io

          res = Net::HTTP.start(url.hostname, url.port, use_ssl: url.scheme == 'https') do |http|
            http.request(req)
          end

          if res != Net::HTTPSuccess
            raise "Failed to push gem: #{res.body}"
          end
        end
      end

      private

      def gems_get_uri
        URI.parse(@base_url + '/api/v1/gems')
      end

      def gems_push_uri
        URI.parse(@base_url + '/api/v1/gems?overwrite=true')
      end
    end
  end
end
