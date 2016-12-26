require 'git'

module Released
  module Goals
    class GitTagExists < Released::Goal
      identifier :git_tag_exists

      def initialize(config)
        @working_dir = config.fetch('working_dir')
        @name = config.fetch('name')
        @ref = config.fetch('ref')
        @signed = config.fetch('signed', false)
        @annotated = config.fetch('annotated', false)
        @message = config.fetch('message', nil)
      end

      def to_s
        "Git tag exists (#{@name}, ref #{@ref})"
      end

      def try_achieve
        opts = {}
        opts[:sign] = @signed
        opts[:annotate] = @annotated
        opts[:message] = @message
        g.add_tag(@name, @ref, opts)
      end

      def achieved?
        g.tags.any? { |t| t.name == @name && t.sha == ref_sha }
      end

      def failure_reason
        tag_with_name = g.tags.find { |t| t.name == @name }
        if tag_with_name
          "tag named #{@name} points to different rev"
        else
          "no tag named #{@name} exists"
        end
      end

      private

      def g
        @_g ||= Git.open(@working_dir)
      end

      def ref_sha
        g.object(@ref).sha
      end
    end
  end
end
