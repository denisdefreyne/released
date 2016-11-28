module Released
  class PipelineReader
    def initialize(filename)
      @filename = filename
    end

    def read
      yaml = YAML.load_file(@filename)

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
  end
end
