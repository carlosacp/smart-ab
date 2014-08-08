require 'smart_ab/engine'
require 'smart_ab/random'
require 'smart_ab/probability_range'
require 'smart_ab/probability_range_builder'

module SmartAb
  ProbabilityOverflow = Class.new(StandardError)
  ProbabilityUnderflow = Class.new(StandardError)
  RangeAxiom = Struct.new :percentual, :index
end
