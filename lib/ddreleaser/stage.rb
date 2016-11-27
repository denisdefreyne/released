module DDReleaser
  class Stage
    attr_reader :name
    attr_reader :plugins

    def initialize(name, plugins)
      @name = name
      @plugins = plugins
    end
  end
end
