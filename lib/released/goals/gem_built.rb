module Released
  module Goals
    class GemBuilt < Released::Goal
      identifier :gem_built

      def initialize(config = {})
        @gemspec_file_path = config.fetch(:gemspec_file_path)
      end

      def self.from_yaml(yaml)
        new(gemspec_file_path: yaml['gem_built'])
      end

      def to_s
        "gem built (#{@gemspec_file_path})"
      end

      def try_achieve
        Dir['*.gem'].each { |f| FileUtils.rm_f(f) }

        stdout = ''
        stderr = ''
        piper = Nanoc::Extra::Piper.new(stdout: stdout, stderr: stderr)

        begin
          piper.run(['gem', 'build', @gemspec_file_path], [])
          Released::Success.new(self.class)
        rescue
          Released::Failure.new(self.class, "non-zero exit status (error = #{stderr})")
        end
      end
    end
  end
end
