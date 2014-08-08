require 'spec_helper'


module SmartAb

  ProbabilityOverflow = Class.new(StandardError)
  ProbabilityUnderflow = Class.new(StandardError)
  RangeAxiom = Struct.new :percentual, :index

  class Random
    def self.generate
      (rand*100).to_i
    end
  end

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
        puts "P = #{prob_ranges.last.percentual}"
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
      random = Random.generate
      selected_range = distribute_range(*prob).select { |k, v|
        k === random
      }

      selected_range.values.first
    end
  end
end


describe "Qqq" do

  it "should pass" do
    expect(SmartAb::Random).to receive(:generate).and_return(10);
    a = (SmartAb::Engine.new([])).distribute([0, 30, 70])
    expect(a).to be 1
  end

  it "should pass" do
    expect(SmartAb::Random).to receive(:generate).and_return(80)
    a = (SmartAb::Engine.new([])).distribute([0, 30, 70])
    expect(a).to be 2
  end

  xit "should pass" do
    a = (SmartAb::Engine.new([])).distribute([70,30], [:a, :b])
    expect(a).to be :a
  end

end

describe "session persistence" do
  context "for 3 args" do

    it {
      session = []
      ab = SmartAb::Engine.new(session)
      result1 = ab.distribute([10,10,10,10,10,10,10,10,10,10])
      result2 = ab.distribute([10,10,10,10,10,10,10,10,10,10])
      result3 = ab.distribute([10,10,10,10,10,10,10,10,10,10])
      result4 = ab.distribute([10,10,10,10,10,10,10,10,10,10])

      expect(result1).to eq result2
      expect(result2).to eq result3
      expect(result3).to eq result4
    }
  end
end

describe "distribute_range" do
  context "for 3 args" do
    it "kkq" do
      a = (SmartAb::Engine.new([])).distribute_range(0, 30, 70)
      expect(a).to eq({
          (0..0) => 0,
          (1..30) => 1,
          (31..100) => 2
      })
    end

    it {
      a = SmartAb::Engine.new([])
      expect(a.distribute_range(25,25,25,25)).to eq({
          (0..25) => 0,
          (26..50) => 1,
          (51..75) => 2,
          (76..100) => 3
      })
    }

    it "test" do
      ab = SmartAb::Engine.new([])
      result4 = ab.distribute_range(10,10,10,10,10,10,10,10,10,10)
      expect(result4).to eq ({
        (0..10) => 0,
        (11..20) => 1,
        (21..30) => 2,
        (31..40) => 3,
        (41..50) => 4,
        (51..60) => 5,
        (61..70) => 6,
        (71..80) => 7,
        (81..90) => 8,
        (91..100) => 9
      })
    end

    it "kkq" do
      a = (SmartAb::Engine.new([])).distribute_range(60, 10, 30)
      expect(a).to eq({
          (0..10) => 1,
          (11..40) => 2,
          (41..100) => 0
      })
    end
  end

  context "for 2 args" do
    it "kkq" do
      a = (SmartAb::Engine.new([])).distribute_range(0, 100)
      expect(a).to eq({
          (0..0) => 0,
          (1..100) => 1
      })
    end

    it "kkq" do
      a = (SmartAb::Engine.new([])).distribute_range(30, 70)
      expect(a).to eq({
          (0..30) => 0,
          (31..100) => 1
      })
    end

    it "kkq" do
      a = (SmartAb::Engine.new([])).distribute_range(70, 30)
      expect(a).to eq({
          (0..30) => 1,
          (31..100) => 0
      })
    end

    it "kkq" do
      expect{ (SmartAb::Engine.new([])).distribute_range(100, 100) }.to raise_error(SmartAb::ProbabilityOverflow)
    end

    it "kkq" do
      expect{ (SmartAb::Engine.new([])).distribute_range(30, 30) }.to raise_error(SmartAb::ProbabilityUnderflow)
    end

  end
end
