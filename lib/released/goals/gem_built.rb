module Released
  module Goals
    class GemBuilt < Released::Goal
      identifier :gem_built

      def initialize(config = {})
        @name = config.fetch(:name)
        @version = config.fetch(:version)
      end

      def self.from_yaml(yaml)
        new(
          name: yaml['gem_built']['name'],
          version: yaml['gem_built']['version'],
        )
      end

      def to_s
        "gem built (#{@name})"
      end

      def try_achieve
        Dir['*.gem'].each { |f| FileUtils.rm_f(f) }

        stdout = ''
        stderr = ''
        piper = Nanoc::Extra::Piper.new(stdout: stdout, stderr: stderr)

        begin
          gemspec_file_path = "#{@name}.gemspec"
          piper.run(['gem', 'build', gemspec_file_path], [])
          Released::Success.new(self.class)
        rescue
          Released::Failure.new(self.class, "non-zero exit status (error = #{stderr})")
        end
      end

      def achieved?
        Dir['*.gem'].include?(expected_name)
      end

      def failure_reason
        "Expected the file #{expected_name} to have been created"
      end

      private

      def expected_name
        @_expected_name ||= @name + '-' + @version + '.gem'
      end
    end
  end
end
