module SmartAb
  class ProbabilityRange
    attr_accessor :start_range, :end_range, :index, :range

    def initialize(start_range, end_range, index)
      self.start_range = start_range
      self.end_range = end_range
      self.index = index
    end

    def range
      (self.start_range..self.end_range)
    end

    def after_end_range
      self.end_range+1
    end

    def percentual
      end_range-start_range
    end
  end
end
