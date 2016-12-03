require 'git'

module Released
  module Goals
    class GitRefPushed < Released::Goal
      identifier :git_ref_pushed

      def initialize(config)
        @working_dir = config.fetch('working_dir')
        @remote = config.fetch('remote')
        @ref = config.fetch('ref')
      end

      def try_achieve
        g.push(@remote, @ref)
      end

      def achieved?
        local_sha == remote_sha
      end

      def failure_reason
        "HEAD does not exist on #{@remote}/#{@ref}"
      end

      private

      def g
        @_g ||= Git.open(@working_dir)
      end

      def remote_sha
        g.gcommit("#{@remote}/#{@ref}").sha
      rescue
        nil
      end

      def local_sha
        g.object('HEAD').sha
      end
    end
  end
end
