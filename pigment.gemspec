lib = File.expand_path('../lib/', __FILE__)
$:.unshift lib unless $:.include?(lib)

require 'pigment'

Gem::Specification.new do |s|
  s.name          = 'pigment'
  s.version       = Pigment::VERSION
  s.summary       = 'A rgb color gem, with a list of 750 different colors.'
  s.description   = 'A rgb color gem, with a list of 750 different colors defined within 869 names.'
  s.license       = 'MIT'
  s.authors       = %w'P3t3rU5 SilverPhoenix99'
  s.email         = %w'pedro.megastore@gmail.com silver.phoenix99@gmail.com'
  s.homepage      = 'https://github.com/P3t3rU5/pigment'
  s.require_paths = %w'lib'
  s.files         = Dir['{lib/**/*.rb,*.md}']
  s.post_install_message = <<-eos
+----------------------------------------------------------------------------+
  Thanks for choosing Pigment.

  ==========================================================================
  #{Pigment::VERSION} Changes:
    - Corrected Color#== to include alpha

  ==========================================================================

  If you like what you see, support us on Pledgie:
    http://www.pledgie.com/campaigns/18945

  If you find any bugs, please report them on
    https://github.com/P3t3rU5/pigment/issues

+----------------------------------------------------------------------------+
  eos
end