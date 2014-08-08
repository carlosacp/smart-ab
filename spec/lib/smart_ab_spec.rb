require 'spec_helper'

# FactoryGirl.define do
# 	factory :range, class:Hash do
# 		initialize_with { {
# 				(0..0) => 0,
# 				(1..30) => 1,
# 				(31..100) => 2
# 		} }
# 	end
# end

VO = Struct.new :prob, :element
RangeEl = Struct.new :range, :element

class Random
	def self.generate
		(rand*100).to_i
	end
end

def create_range_el(last_ele, new_end_range, new_element)
	last_range = last_ele.range
	new_start_range = last_range.last + 1
	new_range = (new_start_range..new_end_range)
	RangeEl.new(new_range, new_element)
end

def distribute(prob)
	range = distribute_range(*prob)
	random = Random.generate

	selected_range = range.select { |k, v|
		k === random
	}

	selected_range.values.first
end

def distribute_range(*probs)
	sum = probs.inject(&:+)
	raise ProbabilityOverflow if (sum > 100)
	raise ProbabilityUnderflow if (sum < 100)

	mapped = probs.map.with_index { |prob, index| VO.new prob, index }
	mapped.sort! {|a,b| a.prob <=> b.prob }

	start_element = [ RangeEl.new((0..mapped[0].prob), mapped[0].element) ]
	resp = mapped[1..-2].inject(start_element) do |memo, vo|
		memo << create_range_el(memo.last, vo.prob, vo.element)
		memo
	end

	resp << create_range_el(resp.last, 100, mapped.last.element)

	resp.inject({}) do |memo, ele|
		memo[ele.range] = ele.element
		memo
	end
end

ProbabilityOverflow = Class.new(StandardError)
ProbabilityUnderflow = Class.new(StandardError)


describe "Qqq" do

	it "should pass" do
		expect(Random).to receive(:generate).and_return(10);
		a = distribute([0, 30, 70])
		expect(a).to be 1
	end

	it "should pass" do
		expect(Random).to receive(:generate).and_return(80)
		a = distribute([0, 30, 70])
		expect(a).to be 2
	end

	xit "should pass" do
		a = distribute([70,30], [:a, :b])
		expect(a).to be :a
	end

end

describe "distribute_range" do


	context "for 3 args" do
		it "kkq" do
			a = distribute_range(0, 30, 70)
			expect(a).to eq({
					(0..0) => 0,
					(1..30) => 1,
					(31..100) => 2
			})
		end

		it "kkq" do
			a = distribute_range(60, 10, 30)
			expect(a).to eq({
					(0..10) => 1,
					(11..30) => 2,
					(31..100) => 0
			})
		end
	end

	context "for 2 args" do
		it "kkq" do
			a = distribute_range(0, 100)
			expect(a).to eq({
					(0..0) => 0,
					(1..100) => 1
			})
		end

		it "kkq" do
			a = distribute_range(30, 70)
			expect(a).to eq({
					(0..30) => 0,
					(31..100) => 1
			})
		end

		it "kkq" do
			a = distribute_range(70, 30)
			expect(a).to eq({
					(0..30) => 1,
					(31..100) => 0
			})
		end

		it "kkq" do
			expect{ distribute_range(100, 100) }.to raise_error(ProbabilityOverflow)
		end

		it "kkq" do
			expect{ distribute_range(30, 30) }.to raise_error(ProbabilityUnderflow)
		end

	end
end
