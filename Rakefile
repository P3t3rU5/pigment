require 'yard'
require 'rspec/core/rake_task'

YARD::Rake::YardocTask.new do |t|
  t.files   = ['lib/**/*.rb']
  t.stats_options = ['--list-undoc']
end

desc "Run the specs."
RSpec::Core::RakeTask.new { |t| t.pattern = "spec/**/*_spec.rb" }