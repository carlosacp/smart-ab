Gem::Specification.new do |s|
  s.name        = 'smartab'
  s.version     = '0.0.0'
  s.date        = '2014-08-08'
  s.summary     = "SmartAb"
  s.description = "A gem to execute A/B tests server-side"
  s.authors     = ["Carlos Pereira", "Renato Alves"]
  s.email       = ''
  s.files       = [
    "lib/smart_ab.rb",
    "lib/smart_ab/engine.rb",
    "lib/smart_ab/random.rb",
    "lib/smart_ab/probability_range.rb",
    "lib/smart_ab/probability_range_builder.rb"
  ]
  s.homepage    =
    'https://github.com/carlosacp/smart-ab'
  s.license       = 'MIT'
end
