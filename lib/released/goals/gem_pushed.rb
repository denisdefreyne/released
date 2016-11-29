module Released
  module Goals
    class GemPushed < Released::Goal
      identifier :gem_pushed

      def initialize(config = {})
        @name = config.fetch('name')
        @version = config.fetch('version')

        @rubygems_repo = Released::Repos::RubyGems.new(
          authorization: config.fetch('authorization'),
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
