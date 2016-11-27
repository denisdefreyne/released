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

    def precheck_safe
      precheck if precheck?
    rescue
      DDReleaser::Failure.new(self.class, 'unexpected error')
    end

    def precheck?
      respond_to?(:precheck)
    end

    # @abstract
    def run
      # TODO: maybe rename to #achieve?
      raise NotImplementedError
    end
  end
end
