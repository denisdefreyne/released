module Released
  module Goals
    # TODO: rename
    class Shell < Released::Goal
      identifier :shell

      def initialize(config = {})
        @command = config.fetch('command')
      end

      def to_s
        "shell (#{@command})"
      end

      def effectful?
        false
      end

      def assess
        sleep 1
      end

      def try_achieve
        stdout = ''
        stderr = ''
        piper = Released::Piper.new(stdout: stdout, stderr: stderr)

        begin
          piper.run(@command, [])
        rescue
          raise "Failed execute command!\n\nstderr:\n#{stderr}\n\nstdout:\n#{stdout}"
        end
      end

      def achieved?
        false
      end

      def failure_reason
        'command not executed'
      end
    end
  end
end
