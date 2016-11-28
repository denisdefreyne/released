module Released
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
    rescue => e
      Released::Failure.new(
        self.class,
        "unexpected error:\n\n#{e.message}\n\n#{e.backtrace.join("\n")}",
      )
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
