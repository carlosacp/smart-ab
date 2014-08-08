module SmartAb
  class ProbabilityRangeBuilder
    attr_accessor :probabilities, :mapped_probabilities

    def initialize(probabilities)
      self.probabilities = probabilities
      self.mapped_probabilities = self.map
      self.sort
    end

    def map
      probabilities.map.with_index { |percentual, index| RangeAxiom.new percentual, index }
    end

    def sort
      mapped_probabilities.sort! {|range_axiom1,range_axiom2| range_axiom1.percentual <=> range_axiom2.percentual }
    end

    def build_array
      cumulative_percentage = 0
      resp = mapped_probabilities[1..-2].inject(first_probability_range) do |prob_ranges, axiom|
        prob_ranges << probability_range(prob_ranges.last.after_end_range, prob_ranges.last.end_range+axiom.percentual, axiom.index)
        cumulative_percentage += prob_ranges.last.percentual
        prob_ranges
      end
      resp << last_probability_range(resp.last.after_end_range)
    end

    def first_probability_range
      [ probability_range(0, mapped_probabilities.first.percentual, mapped_probabilities.first.index) ]
    end

    def last_probability_range(start_range)
      probability_range(start_range, 100, mapped_probabilities.last.index)
    end

    def probability_range(start_range, end_range, index)
      ProbabilityRange.new(start_range, end_range, index)
    end
  end
end
