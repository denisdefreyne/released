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

      def to_s
        "Git ref pushed (#{@remote}/#{@ref})"
      end

      def try_achieve
        g.push(@remote, @ref)
      end

      def achieved?
        local_sha == remote_sha
      end

      def failure_reason
        if remote_sha
          "ref #{@ref} (#{abbr local_sha}) is not the same as #{@remote}/#{@ref} (#{abbr remote_sha})"
        else
          "ref #{@ref} (#{abbr local_sha}) does not exist on remote #{@remote}"
        end
      end

      private

      def g
        @_g ||= Git.open(@working_dir)
      end

      def abbr(sha)
        sha && sha[0..7]
      end

      def remote_sha
        g.gcommit("#{@remote}/#{@ref}").sha
      rescue
        nil
      end

      def local_sha
        g.object(@ref).sha
      end
    end
  end
end
