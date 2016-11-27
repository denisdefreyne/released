module DDReleaser
  module Goals
    # TODO: rename
    class Shell < DDReleaser::Goal
      identifier :shell

      def initialize(config = {})
        @command = config.fetch(:command)
      end

      def self.from_yaml(yaml)
        new(command: yaml)
      end

      def inspect
        "#{self.class.name}(command = #{@command})"
      end

      def run
        stdout = ''
        stderr = ''
        piper = Nanoc::Extra::Piper.new(stdout: stdout, stderr: stderr)

        begin
          piper.run(@command, [])
          DDReleaser::Success.new(self.class)
        rescue
          DDReleaser::Failure.new(self.class, "non-zero exit status (error = #{stderr})")
        end
      end
    end
  end
end
