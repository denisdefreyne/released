module DDReleaser
  class Goal
    extend DDPlugin::Plugin

    # @abstract
    def self.from_yaml(_yaml)
      raise NotImplementedError
    end

    # @abstract
    def initialize(_config = {})
      raise NotImplementedError
    end

    def asses_safe
      asses if asses?
    rescue
      DDReleaser::Failure.new(self.class, 'unexpected error')
    end

    def asses?
      respond_to?(:asses)
    end

    # @abstract
    def achieve
      raise NotImplementedError
    end
  end
end
