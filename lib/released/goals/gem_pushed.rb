module Released
  module Goals
    class GemPushed < Released::Goal
      identifier :gem_pushed

      RUBYGEMS_BASE_URL = 'http://0.0.0.0:9292'.freeze

      def initialize(config = {})
        @name = config.fetch(:name)
        @version = config.fetch(:version)
        @authorization = config.fetch(:authorization)

        @rubygems_base_url = config.fetch(:rubygems_base_url, RUBYGEMS_BASE_URL)
      end

      def self.from_yaml(yaml)
        new(
          name: yaml['gem_pushed']['name'],
          version: yaml['gem_pushed']['version'],
          authorization: yaml['gem_pushed']['authorization'],
        )
      end

      def to_s
        "gem pushed (#{@name})"
      end

      def assess
        # FIXME: verify that authorization does not end with a newline

        res = names_and_versions_of_owned_gems
        unless res
          return Released::Failure.new(self.class, 'authorization failed')
        end

        names = res.map { |e| e[:name] }
        unless names.include?(@name)
          return Released::Failure.new(self.class, 'list of owned gems does not include request gem')
        end

        Released::Success.new(self.class)
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

          case res
          when Net::HTTPSuccess
            Released::Success.new(self.class)
          else
            Released::Failure.new(self.class, res.body)
          end
        end
      end

      def achieved?
        expected = { name: @name, version: @version }
        names_and_versions_of_owned_gems.include?(expected)
      end

      def failure_reason
        "expected list of gems to contain “#{@name}”, version #{@version}"
      end

      private

      def names_and_versions_of_owned_gems
        url = gems_get_uri

        req = Net::HTTP::Get.new(url)
        req['Authorization'] = @authorization

        res = Net::HTTP.start(url.hostname, url.port, use_ssl: url.scheme == 'https') do |http|
          http.request(req)
        end

        if res.is_a?(Net::HTTPSuccess)
          body = JSON.parse(res.body)
          body.map { |e| { name: e['name'], version: e['version'] } }
        end
      end

      def gems_get_uri
        URI.parse(@rubygems_base_url + '/api/v1/gems')
      end

      def gems_push_uri
        URI.parse(@rubygems_base_url + '/api/v1/gems?overwrite=true')
      end
    end
  end
end
