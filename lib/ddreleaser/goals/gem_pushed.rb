module DDReleaser
  module Goals
    class GemPushed < DDReleaser::Goal
      identifier :gem_pushed

      def initialize(config = {})
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

      def asses
        uri = URI.parse(@rubygems_base_url + '/api/v1/gems.json')

        req = Net::HTTP::Get.new(uri)
        req['Authorization'] = @authorization

        res = Net::HTTP.start(uri.hostname, uri.port, use_ssl: uri.scheme == 'https') do |http|
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
        # gem_name, gem_file, authorization
        # TODO

        DDReleaser::Success.new(self.class)
      end
    end
  end
end
