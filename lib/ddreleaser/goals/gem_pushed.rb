module DDReleaser
  module Goals
    class GemPushed < DDReleaser::Goal
      identifier :gem_pushed

      def initialize(config = {})
        # FIXME: make only gem_name necessary

        @gem_name = config.fetch(:gem_name)
        @gem_file_path = config.fetch(:gem_file_path)
        @authorization = config.fetch(:authorization)

        @rubygems_base_url = config.fetch(:rubygems_base_url, 'https://rubygems.org')
      end

      def self.from_yaml(yaml)
        new(
          gem_file_path: yaml['gem_pushed']['gem_file_path'],
          gem_name: yaml['gem_pushed']['gem_name'],
          authorization: yaml['gem_pushed']['authorization'],
        )
      end

      def to_s
        "gem pushed (#{@gem_name})"
      end

      # FIXME: I forgot the trailing S, ugh
      def asses
        url = URI.parse(@rubygems_base_url + '/api/v1/gems.json')

        req = Net::HTTP::Get.new(url)
        req['Authorization'] = @authorization

        res = Net::HTTP.start(url.hostname, url.port, use_ssl: url.scheme == 'https') do |http|
          http.request(req)
        end

        unless res.is_a?(Net::HTTPSuccess)
          return DDReleaser::Failure.new(self.class, 'authorization failed')
        end

        body = JSON.parse(res.body)
        unless body.any? { |e| e['name'] == @gem_name }
          return DDReleaser::Failure.new(self.class, 'list of owned gems does not include request gem')
        end

        DDReleaser::Success.new(self.class)
      end

      def achieve
        # FIXME: what if there are none?
        # FIXME: what if there are multiple?
        filename = Dir[@gem_name + '-*.gem'].first

        gem_size = File.size(filename)
        File.open(filename, 'r') do |io|
          url = URI.parse("http://0.0.0.0:9292/api/v1/gems?overwrite=true")

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
            DDReleaser::Success.new(self.class)
          else
            DDReleaser::Failure.new(self.class, res.body)
          end
        end
      end
    end
  end
end
