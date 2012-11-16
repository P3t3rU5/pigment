lib = File.expand_path('../lib/', __FILE__)
$:.unshift lib unless $:.include?(lib)

require 'pigment'

Gem::Specification.new do |s|
  s.name          = 'pigment'
  s.version       = Pigment::VERSION
  s.summary       = 'A rgb color gem, with a list of 750 diferent colors.'
  s.description   = 'A rgb color gem, with a list of 750 diferent colors defined within 869 names.'
  s.authors       = %w'P3t3rU5 SilverPhoenix99'
  s.email         = %w'pedro.megastore@gmail.com silver.phoenix99@gmail.com'
  s.homepage      = 'https://github.com/P3t3rU5/pigment'
  s.require_paths = %w'lib'
  s.files         = Dir['{lib/**/*.rb,*.md}']
end