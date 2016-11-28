module Released
  class Stage
    attr_reader :name
    attr_reader :goals

    def initialize(name, goals)
      @name = name
      @goals = goals
    end
  end
end
