module SmartAb
  class Engine
    attr_accessor :session

    def initialize(session)
      self.session = session
    end

    def distribute_range(*probs)
      sum = probs.inject(&:+)
      raise ProbabilityOverflow if (sum > 100)
      raise ProbabilityUnderflow if (sum < 100)

      probc = ProbabilityRangeBuilder.new(probs)
      probc.build_array.inject({}) do |memo, probability_range|
        memo[probability_range.range] = probability_range.index
        memo
      end
    end

    def distribute(prob)
      return session[:participating] unless session[:participating].nil?

      random = Random.generate
      selected_range = distribute_range(*prob).select { |k, v|
        k === random
      }

      session[:participating] = selected_range.values.first
      selected_range.values.first
    end
  end
end
