module DDReleaser
  class Step
    attr_reader :name
    attr_reader :goal

    def initialize(name, goal)
      @name = name
      @goal = goal
    end
  end
end
