module Released
  class PipelineReader
    def initialize(filename)
      @filename = filename
    end

    def read
      yaml = transform(YAML.load_file(@filename))

      goals = []

      yaml['goals'].each do |goal_yaml|
        name = goal_yaml.keys.first
        config = goal_yaml[name]
        # TODO: what if there are more?

        goals << Released::Goal.named(name.to_sym).new(config)
      end

      goals
    end

    private

    def transform(obj)
      case obj
      when Hash
        transform_hash(obj)
      when Array
        transform_array(obj)
      when String
        transform_string(obj)
      else
        obj
      end
    end

    def transform_hash(hash)
      hash.each_with_object({}) do |(key, value), memo|
        memo[key] = transform(value)
      end
    end

    def transform_array(array)
      array.map do |elem|
        transform(elem)
      end
    end

    def transform_string(string)
      case string
      when /\Aenv!(.*)/
        ENV.fetch(Regexp.last_match(1))
      when /\Ash!(.*)/
        `#{Regexp.last_match(1)}`
      when /\A-----BEGIN PGP MESSAGE-----/
        decrypt(string)
      else
        string
      end
    end

    def decrypt(string)
      stdout = ''
      stderr = ''

      piper = Released::Piper.new(stdout: stdout, stderr: stderr)
      piper.run(['gpg', '--decrypt', '--no-tty'], string)

      stdout
    end
  end
end
