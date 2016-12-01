module Released
  module Goals
    class FileExists < Released::Goal
      identifier :file_exists

      def initialize(config)
        @filename = config.fetch('filename')
        @contents = config.fetch('contents')
      end

      def to_s
        "file exists (#{@filename})"
      end

      def try_achieve
        File.write(@filename, @contents)
      end

      def achieved?
        File.file?(@filename) && File.read(@filename) == @contents
      end

      def failure_reason
        if !File.file?(@filename)
          "file `#{@filename}` does not exist"
        elsif File.read(@filename) != @contents
          "file `#{@filename}` does not have the expected contents"
        else
          'unknown reason'
        end
      end
    end
  end
end
