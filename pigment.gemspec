require_relative 'lib/pigment/version'

Gem::Specification.new do |gem|
  gem.name          = 'pigment'
  gem.version       = Pigment::VERSION
  gem.summary       = 'A rgb color gem, with a list of 750 different colors.'
  gem.description   = 'A rgb color gem, with a list of 750 different colors defined within 869 names.'
  gem.license       = 'MIT'
  gem.authors       = %w'P3t3rU5 SilverPhoenix99'
  gem.email         = %w'pedro.megastore@gmail.com silver.phoenix99@gmail.com'
  gem.homepage      = 'https://github.com/P3t3rU5/pigment'
  gem.require_paths = %w'lib'
  gem.files         = Dir['{lib/**/*.rb,*.md}']
  gem.add_development_dependency 'rspec', '~> 3'
  gem.add_development_dependency 'pry', '~> 0.13'
  gem.add_development_dependency 'simplecov', '~> 0.19'
  gem.add_development_dependency 'rake', '~> 13'
  gem.add_development_dependency 'yard', '~> 0.9'
  gem.post_install_message = <<-eos
+----------------------------------------------------------------------------+
  Thanks for choosing Pigment.
  --------------------------------------------------------------------------
#{File.read('CHANGELOG.md')}
  --------------------------------------------------------------------------
  If you find any bugs, please report them on
    https://github.com/P3t3rU5/pigment/issues
+----------------------------------------------------------------------------+
  eos
end