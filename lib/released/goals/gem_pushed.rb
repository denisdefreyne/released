module Released
  module Goals
    class GemPushed < Released::Goal
      identifier :gem_pushed

      RUBYGEMS_BASE_URL = 'http://0.0.0.0:9292'.freeze

      def initialize(config = {})
        @gem_name = config.fetch(:gem_name)
        @authorization = config.fetch(:authorization)

        @rubygems_base_url = config.fetch(:rubygems_base_url, RUBYGEMS_BASE_URL)
      end

      def self.from_yaml(yaml)
        new(
          gem_name: yaml['gem_pushed']['gem_name'],
          authorization: yaml['gem_pushed']['authorization'],
        )
      end

      def to_s
        "gem pushed (#{@gem_name})"
      end

      def assess
        url = gems_get_uri

        req = Net::HTTP::Get.new(url)
        req['Authorization'] = @authorization

        res = Net::HTTP.start(url.hostname, url.port, use_ssl: url.scheme == 'https') do |http|
          http.request(req)
        end

        unless res.is_a?(Net::HTTPSuccess)
          return Released::Failure.new(self.class, 'authorization failed')
        end

        body = JSON.parse(res.body)
        unless body.any? { |e| e['name'] == @gem_name }
          return Released::Failure.new(self.class, 'list of owned gems does not include request gem')
        end

        Released::Success.new(self.class)
      end

      def try_achieve
        # FIXME: what if there are none?
        # FIXME: what if there are multiple?
        filename = Dir[@gem_name + '-*.gem'].first

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
        # FIXME
        true
      end

      private

      def gems_get_uri
        URI.parse(@rubygems_base_url + '/api/v1/gems')
      end

      def gems_push_uri
        URI.parse(@rubygems_base_url + '/api/v1/gems?overwrite=true')
      end
    end
  end
end
