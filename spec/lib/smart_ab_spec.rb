require 'spec_helper'

describe SmartAb do
  before(:each) {
    @ab = subject::Engine.new({})
  }

  context "should distribute percentages correctly" do
    {
      1 => { "random" => 10, "percentages" => [0,30,70], "expected" => 1 },
      2 => { "random" => 80, "percentages" => [0,30,70], "expected" => 2 },
      3 => { "random" => 10, "percentages" => [70,30], "expected" => 1 },
    }.each do |k,v|
      it "percentages #{v['percentages']} and random = #{v['random']} should return #{v['expected']}" do
        expect(subject::Random).to receive(:generate).and_return(v['random'])
        expect(@ab.distribute("sample-test",v['percentages'])).to eq v['expected']
      end
    end
  end

  context "session persistence" do
    it "should return always the same index after the first distribute (session store)" do
      session = {}
      ab = subject::Engine.new(session)
      result1 = ab.distribute("sample-test",[10,10,10,10,10,10,10,10,10,10])
      result2 = ab.distribute("sample-test",[10,10,10,10,10,10,10,10,10,10])
      result3 = ab.distribute("sample-test",[10,10,10,10,10,10,10,10,10,10])
      result4 = ab.distribute("sample-test",[10,10,10,10,10,10,10,10,10,10])

      expect(result1).to eq result2
      expect(result2).to eq result3
      expect(result3).to eq result4
    end

    it "should return the same Index if session is already set" do
      session = { :participating => 3 }
      ab = subject::Engine.new(session)
      result1 = ab.distribute("sample-test",[10,10,10,10,10,10,10,10,10,10])
      expect(result1).to eq session["smartab_sample-test"]
    end

    it "should allow multiple persistence for simultaneous experiments" do
      session = {}
      ab = subject::Engine.new(session)
      expect(ab.session).to eq({})

      expect(subject::Random).to receive(:generate).and_return(99)
      result1 = ab.distribute("experiment-1", [10,10,10,10,10,10,10,10,10,10])
      expect(ab.session).to eq({'smartab_experiment-1' => 9})

      expect(subject::Random).to receive(:generate).and_return(1)
      result2 = ab.distribute("experiment-2", [10,10,10,10,10,10,10,10,10,10])
      expect(ab.session).to eq({'smartab_experiment-1' => 9,'smartab_experiment-2' => 0})
    end
  end

  context "raise exception for (over|under)flow cases" do
    {
      "ProbabilityOverflow" => [100,100],
      "ProbabilityUnderflow" => [30,30]
    }.each do |k,v|
      it "should raise #{k} exception for percentage sets like #{v}" do
        expect { @ab.distribute_range(*v).to raise_error(subject.send(k.to_sym))  }
      end
    end
  end

  context "testing several variations of percentage axioms" do
    intervals = {
      [0,100] => {(0..0) => 0, (1..100) => 1},
      [30,70] => {(0..30) => 0, (31..100) => 1},
      [70,30] => {(0..30) => 1, (31..100) => 0},
      [0,30,70] => {(0..0) => 0, (1..30) => 1, (31..100) => 2},
      [60,10,30] => {(0..10) => 1, (11..40) => 2,(41..100) => 0},
      [25,25,25,25] => {(0..25) => 0, (26..50) => 1, (51..75) => 2, (76..100) => 3},
      [10,10,10,10,10,10,10,10,10,10] => {(0..10) => 0,(11..20) => 1,(21..30) => 2,(31..40) => 3,(41..50) => 4,(51..60) => 5,(61..70) => 6,(71..80) => 7, (81..90) => 8,(91..100) => 9}
    }

    intervals.each do |k, v|
      it "testing percentages: #{k.join(',')}" do
        result = @ab.distribute_range(*k)
        expect(result).to eq v
      end
    end
  end
end
