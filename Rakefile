require 'rubocop/rake_task'
require 'rspec/core/rake_task'

RuboCop::RakeTask.new(:rubocop) do |task|
  task.options  = %w(--display-cop-names --format simple)
  task.patterns = ['bin/*', 'lib/**/*.rb', 'spec/**/*.rb', 'Gemfile', 'Rakefile', '*.gemspec']
end

RSpec::Core::RakeTask.new(:spec) do |t|
  t.verbose = false
end

task default: [:spec, :rubocop]
