module Released
  module Goals
    class GemPushed < Released::Goal
      identifier :gem_pushed

      RUBYGEMS_BASE_URL = 'http://0.0.0.0:9292'.freeze

      def initialize(config = {})
        @name = config.fetch('name')
        @version = config.fetch('version')
        @authorization = config.fetch('authorization')

        @rubygems_base_url = config.fetch('rubygems_base_url', RUBYGEMS_BASE_URL)

        @rubygems_repo = Released::Repos::RubyGems.new(
          base_url: @rubygems_base_url,
          authorization: @authorization,
        )
      end

      def to_s
        "gem pushed (#{@name})"
      end

      def assess
        unless @rubygems_repo.owned_gems.map(&:name).include?(@name)
          raise 'List of owned gems does not include request gem'
        end
      end

      def try_achieve
        # FIXME: what if there are none?
        # FIXME: what if there are multiple?
        filename = Dir[@name + '-*.gem'].first

        gem_size = File.size(filename)
        File.open(filename, 'r') do |io|
          url = gems_push_uri

          req = Net::HTTP::Post.new(url)
          req['Authorization'] = @authorization
          req['Content-Length'] = gem_size
          req.body_stream = io

          # FIXME: use actual base URL
          res = Net::HTTP.start(url.hostname, url.port, use_ssl: url.scheme == 'https') do |http|
            http.request(req)
          end

          if res != Net::HTTPSuccess
            raise "Failed to push gem: #{res.body}"
          end
        end
      end

      def achieved?
        @rubygems_repo.owned_gems.include? { |g| g.name == @name && g.version == @version }
      end

      def failure_reason
        "expected list of gems to contain “#{@name}”, version #{@version}"
      end

      private

      def gems_push_uri
        URI.parse(@rubygems_base_url + '/api/v1/gems?overwrite=true')
      end
    end
  end
end
