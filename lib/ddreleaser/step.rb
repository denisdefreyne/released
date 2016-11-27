module DDReleaser
  class Step
    attr_reader :name
    attr_reader :plugin

    def initialize(name, plugin)
      @name = name
      @plugin = plugin
    end
  end
end
