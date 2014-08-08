require 'spec_helper'


module SmartAb

	ProbabilityOverflow = Class.new(StandardError)
	ProbabilityUnderflow = Class.new(StandardError)
	VO = Struct.new :prob, :element
	RangeEl = Struct.new :range, :element

	class Random
		def self.generate
			(rand*100).to_i
		end
	end

	class ProbabilityCollection
		attr_accessor :probabilities, :mapped_probabilities

		def initialize(probabilities)
			self.probabilities = probabilities
			self.mapped_probabilities = self.map
			self.sort
		end

		def map
			probabilities.map.with_index { |probability, index| VO.new probability, index }
		end

		def sort
			mapped_probabilities.sort! {|a,b| a.prob <=> b.prob }
		end

		def build
			first_element = [ RangeEl.new((0..mapped_probabilities[0].prob), mapped_probabilities[0].element) ]
			resp = mapped_probabilities[1..-2].inject(first_element) do |memo, vo|
				memo << build_range_el(memo.last, vo.prob, vo.element)
				memo
			end
			last_element = build_range_el(resp.last, 100, mapped_probabilities.last.element)
			resp << last_element
		end

		def build_range_el(last_ele, new_end_range, new_element)
			last_range = last_ele.range
			new_start_range = last_range.last + 1
			new_range = (new_start_range..new_end_range)
			RangeEl.new(new_range, new_element)
		end
	end

	class Engine
		def self.distribute_range(*probs)
			sum = probs.inject(&:+)
			raise ProbabilityOverflow if (sum > 100)
			raise ProbabilityUnderflow if (sum < 100)

			probc = ProbabilityCollection.new(probs)
			probc.build.inject({}) do |memo, ele|
				memo[ele.range] = ele.element
				memo
			end
		end

		def self.distribute(prob)
			range = distribute_range(*prob)
			random = Random.generate

			selected_range = range.select { |k, v|
				k === random
			}

			selected_range.values.first
		end
	end
end


describe "Qqq" do

	it "should pass" do
		expect(SmartAb::Random).to receive(:generate).and_return(10);
		a = SmartAb::Engine.distribute([0, 30, 70])
		expect(a).to be 1
	end

	it "should pass" do
		expect(SmartAb::Random).to receive(:generate).and_return(80)
		a = SmartAb::Engine.distribute([0, 30, 70])
		expect(a).to be 2
	end

	xit "should pass" do
		a = SmartAb::Engine.distribute([70,30], [:a, :b])
		expect(a).to be :a
	end

end

describe "distribute_range" do


	context "for 3 args" do
		it "kkq" do
			a = SmartAb::Engine.distribute_range(0, 30, 70)
			expect(a).to eq({
					(0..0) => 0,
					(1..30) => 1,
					(31..100) => 2
			})
		end

		it "kkq" do
			a = SmartAb::Engine.distribute_range(60, 10, 30)
			expect(a).to eq({
					(0..10) => 1,
					(11..30) => 2,
					(31..100) => 0
			})
		end
	end

	context "for 2 args" do
		it "kkq" do
			a = SmartAb::Engine.distribute_range(0, 100)
			expect(a).to eq({
					(0..0) => 0,
					(1..100) => 1
			})
		end

		it "kkq" do
			a = SmartAb::Engine.distribute_range(30, 70)
			expect(a).to eq({
					(0..30) => 0,
					(31..100) => 1
			})
		end

		it "kkq" do
			a = SmartAb::Engine.distribute_range(70, 30)
			expect(a).to eq({
					(0..30) => 1,
					(31..100) => 0
			})
		end

		it "kkq" do
			expect{ SmartAb::Engine.distribute_range(100, 100) }.to raise_error(SmartAb::ProbabilityOverflow)
		end

		it "kkq" do
			expect{ SmartAb::Engine.distribute_range(30, 30) }.to raise_error(SmartAb::ProbabilityUnderflow)
		end

	end
end
