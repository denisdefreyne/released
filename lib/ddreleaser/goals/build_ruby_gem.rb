require 'uri'
require 'net/http'
require 'json'

require 'nanoc'

module DDReleaser
  module Goals
    class BuildRubyGem < DDReleaser::Goal
      def initialize(config = {})
        @gemspec_file_path = config.fetch(:gemspec_file_path)
      end

      def inspect
        "#{self.class.name}(gemspec_file_path = #{@gemspec_file_path})"
      end

      def run
        Dir['*.gem'].each { |f| FileUtils.rm_f(f) }

        stdout = ''
        stderr = ''
        piper = Nanoc::Extra::Piper.new(stdout: stdout, stderr: stderr)

        begin
          piper.run(['gem', 'build', @gemspec_file_path], [])
          DDReleaser::Success.new(self.class)
        rescue
          DDReleaser::Failure.new(self.class, "non-zero exit status (error = #{stderr})")
        end
      end
    end
  end
end
