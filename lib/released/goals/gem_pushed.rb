module Released
  module Goals
    class GemPushed < Released::Goal
      identifier :gem_pushed

      # FIXME: use actual base URL
      BASE_URL = 'http://0.0.0.0:9292'.freeze

      def initialize(config = {})
        @name = config.fetch('name')
        @version = config.fetch('version')

        @rubygems_repo = Released::Repos::RubyGems.new(
          authorization: config.fetch('authorization'),
          base_url: config.fetch('rubygems_base_url', BASE_URL),
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
        filename = @name + '-' + @version + '.gem'
        unless File.file?(filename)
          raise "no such gem file: #{filename}"
        end

        @rubygems_repo.push_gem(filename)
      end

      def achieved?
        @rubygems_repo.owned_gems.any? { |g| g.name == @name && g.version == @version }
      end

      def failure_reason
        "expected list of gems to contain “#{@name}”, version #{@version}"
      end
    end
  end
end
