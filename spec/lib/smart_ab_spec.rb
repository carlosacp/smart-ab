require 'spec_helper'

def distribute(prob, space)

	#mapped = [[prob[0], space[0]], [prob[1], space[1]]
	#orded = mapped.sort {|el1, el2| el1[0] <=> el2[0] }

end

VO = Struct.new :prob, :element
RangeEl = Struct.new :range, :element

def create_range_el(last_ele, new_end_range, new_element)
	last_range = last_ele.range
	new_start_range = last_range.last + 1
	new_range = (new_start_range..new_end_range)
	RangeEl.new(new_range, new_element)
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


	#first_range = (0..mapped[0].prob)
	#second_range = ((mapped[0].prob + 1)..mapped[1].prob)
	#third_range = ((mapped[1].prob + 1)..100)


	#first_element = mapped[0].element
	#second_element = mapped[1].element
	#third_element = mapped[2].element

	#{
	#	first_range => first_element,
	#	second_range => second_element,
	#	third_range => third_element
	#}




	#first_element = [ [(0..mapped[0][0]), mapped[0][1]] ]

	# ranged_mapped = mapped.inject(first_element) do |last, maps|
	# 	index = last.size
	# 	last_index = atual_value - 1
	# 	last_range = last[last_value]
	#
	# 	hash
	# end
	#
	# index = 0
	# start_element = [ [(0..mapped[0][0]), mapped[0][1]] ]
	#
	# index = 1
	# last_index = actual_element - 1
	# last_range = start_element[last_index][0]
	# new_range = ((last_range.last + 1)..100)
	#
	# range = []
	# ele = []
	# ret = {}
	#
	# index = 0
	#
	# range[index] = (0..mapped[index][0])
	# ele[index] = mapped[index][1]
  # ret[range[index]] = ele[index]
	#
	#
	# index = index + 1
	# range[index] = ((0..mapped[index][0]) + 1)..100)
	# ele[index] = mapped[index][1]
	#
	# ret[range[index]] = ele[index]
	#
	# ret
end

ProbabilityOverflow = Class.new(StandardError)
ProbabilityUnderflow = Class.new(StandardError)

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

describe "Qqq" do

	xit "should pass" do
		a = distribute([0,100], [:a, :b])
		expect(a).to be :b
	end

	xit "should pass" do
		a = distribute([100,0], [:a, :b])
		expect(a).to be :a
	end

	xit "should pass" do
		a = distribute([70,30], [:a, :b])
		expect(a).to be :a
	end

end
