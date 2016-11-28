module Released
  class Result
    attr_reader :klass

    def initialize(klass)
      @klass = klass
    end

    def success?
      raise NotImplementedError
    end

    def failure?
      !success?
    end
  end

  class Success < Result
    def inspect
      "Success(#{@klass})"
    end

    def and(other)
      other
    end

    def success?
      true
    end
  end

  class Failure < Result
    attr_reader :reason

    def initialize(klass, reason)
      super(klass)

      @reason = reason
    end

    def inspect
      "Failure(#{@klass}, reason = #{reason.inspect})"
    end

    def and(_other)
      self
    end

    def success?
      false
    end
  end
end
