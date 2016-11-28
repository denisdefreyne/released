module Released
  class PipelineReader
    def initialize(filename)
      @filename = filename
    end

    def read
      yaml = transform_yaml(YAML.load_file(@filename))

      stages = []

      yaml['stages'].each_pair do |stage_name, stage_yaml|
        goals = []
        stage_yaml.each do |goal_yaml|
          name = goal_yaml.keys.first
          # TODO: what if there are more?

          goal_class = Released::Goal.named(name.to_sym)
          goal = goal_class.from_yaml(goal_yaml)

          goals << goal
        end

        stages << Released::Stage.new(stage_name, goals)
      end

      stages
    end

    def transform_yaml(yaml)
      transform_obj(yaml)
    end

    private

    def transform_obj(obj)
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
        memo[key] = transform_obj(value)
      end
    end

    def transform_array(array)
      array.map do |elem|
        transform_obj(elem)
      end
    end

    def transform_string(string)
      case string
      when /\Aenv!(.*)/
        ENV.fetch($1)
      when /\A-----BEGIN PGP MESSAGE-----/
        decrypt(string)
      else
        string
      end
    end

    def decrypt(string)
      stdout = ''
      stderr = ''

      piper = Nanoc::Extra::Piper.new(stdout: stdout, stderr: stderr)
      piper.run(['gpg', '--decrypt', '--no-tty'], string)

      stdout
    end
  end
end
