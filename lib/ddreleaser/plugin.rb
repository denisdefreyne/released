module DDReleaser
  class Plugin
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
      raise NotImplementedError
    end
  end
end
