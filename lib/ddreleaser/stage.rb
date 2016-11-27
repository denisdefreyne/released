module DDReleaser
  class Stage
    attr_reader :name
    attr_reader :steps

    def initialize(name, steps)
      @name = name
      @steps = steps
    end
  end
end
