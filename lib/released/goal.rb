module Released
  class Goal
    extend DDPlugin::Plugin

    # @abstract
    def initialize(_config = {})
      raise NotImplementedError
    end

    def to_s
      self.class.identifier.to_s
    end

    def assess_safe
      assess if assessable?
    rescue => e
      Released::Failure.new(
        self.class,
        "unexpected error:\n\n#{e.message}\n\n#{e.backtrace.join("\n")}",
      )
    end

    def assessable?
      respond_to?(:assess)
    end

    # @abstract
    def try_achieve
      raise NotImplementedError
    end

    # @abstract
    def achieved?
      raise NotImplementedError
    end

    # @abstract
    def failure_reason
      raise NotImplementedError
    end
  end
end
