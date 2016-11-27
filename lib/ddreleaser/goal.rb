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

    def assess_safe
      assess if assess?
    rescue
      DDReleaser::Failure.new(self.class, 'unexpected error')
    end

    def assess?
      respond_to?(:assess)
    end

    # @abstract
    def try_achieve
      raise NotImplementedError
    end
  end
end
