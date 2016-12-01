require 'octokit'

module Released
  module Goals
    class GitHubReleaseExists < Released::Goal
      identifier :github_release_exists

      def initialize(config)
        @repository_name = config.fetch('repository_name') # e.g. nanoc/nanoc
        @tag = config.fetch('tag')
        @release_notes = config.fetch('release_notes')
      end

      def to_s
        "GitHub release exists (#{@tag} in #{@repository_name})"
      end

      def try_achieve
        client = Octokit::Client.new(netrc: true)
        client.create_release(
          @repository_name, @tag,
          body: @release_notes
        )
      end

      def achieved?
        client = Octokit::Client.new(netrc: true)
        releases = client.releases(@repository_name)
        releases.any? { |r| r.tag_name == @tag }
      end

      def failure_reason
        "no release exists in repository #{@repository_name} for tag #{@tag}"
      end
    end
  end
end
