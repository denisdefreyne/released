module Released
  module Goals
    # TODO: rename
    class Shell < Released::Goal
      identifier :shell

      def initialize(config = {})
        @command = config.fetch(:command)
      end

      def self.from_yaml(yaml)
        new(command: yaml['shell'])
      end

      def to_s
        "shell (#{@command})"
      end

      def try_achieve
        stdout = ''
        stderr = ''
        piper = Nanoc::Extra::Piper.new(stdout: stdout, stderr: stderr)

        begin
          piper.run(@command, [])
          Released::Success.new(self.class)
        rescue
          Released::Failure.new(self.class, "non-zero exit status (error = #{stderr})")
        end
      end

      def achieved?
        # FIXME
        true
      end
    end
  end
end
