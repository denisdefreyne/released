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
      transform_obj(Hamster.from(yaml))
    end

    private

    # FIXME: Hamster::Hash is not ordered!!!
    def transform_obj(obj)
      case obj
      when Hamster::Hash
        transform_hash(obj)
      when Hamster::Vector
        transform_vector(obj)
      when String
        transform_string(obj)
      else
        obj
      end
    end

    def transform_hash(hash)
      hash.map do |key, value|
        [key, transform_obj(value)]
      end
    end

    def transform_vector(vector)
      vector.map do |elem|
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
      piper.run(['gpg', '--decrypt'], string)

      stdout
    end
  end
end
