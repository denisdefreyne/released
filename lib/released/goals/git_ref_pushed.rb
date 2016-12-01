require 'git'

module Released
  module Goals
    class GitRefPushed < Released::Goal
      identifier :git_ref_pushed

      def initialize(config)
        @working_dir = config.fetch('working_dir')
        @remote = config.fetch('remote')
        @branch = config.fetch('branch')
      end

      def try_achieve
        g.push(@remote, @branch)
      end

      def achieved?
        there_branch = g.branches["#{@remote}/#{@branch}"]
        return false if there_branch.nil?
        there = there_branch.gcommit.sha

        here = g.object('HEAD').sha

        here == there
      end

      def failure_reason
        "HEAD does not exist on #{@remote}/#{@branch}"
      end

      private

      def g
        @_g ||= Git.open(@working_dir)
      end
    end
  end
end
