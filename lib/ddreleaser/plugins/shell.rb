require 'uri'
require 'net/http'
require 'json'
require 'shellwords'

require 'nanoc'

module DDReleaser
  module Plugins
    class Shell < DDReleaser::Plugin
      def initialize(config = {})
        @command = config.fetch(:command)
      end

      def inspect
        "#{self.class.name}(command = #{Shellwords.shelljoin @command})"
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
