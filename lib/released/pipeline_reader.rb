module Released
  class PipelineReader
    def initialize(filename)
      @filename = filename
    end

    def read
      yaml = transform_root(YAML.load_file(@filename))

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

    def transform_root(obj)
      vars = transform(obj['vars'], {})
      { 'goals' => transform(obj['goals'], vars) }
    end

    def transform(obj, vars)
      case obj
      when Hash
        transform_hash(obj, vars)
      when Array
        transform_array(obj, vars)
      when String
        transform_string(obj, vars)
      else
        obj
      end
    end

    def transform_hash(hash, vars)
      hash.each_with_object({}) do |(key, value), memo|
        memo[key] = transform(value, vars)
      end
    end

    def transform_array(array, vars)
      array.map do |elem|
        transform(elem, vars)
      end
    end

    def transform_string(string, vars)
      case string
      when /\Aenv!(.*)/
        ENV.fetch(Regexp.last_match(1))
      when /\Ash!(.*)/
        `#{Regexp.last_match(1)}`
      when /\Avar!(.*)/
        vars[Regexp.last_match(1)]
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
