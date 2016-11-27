require_relative 'lib/ddreleaser'

test_spec = DDReleaser::Plugins::Shell.new(
  command: ['bundle', 'exec', 'rake', 'spec'],
)

test_rubocop = DDReleaser::Plugins::Shell.new(
  command: ['bundle', 'exec', 'rake', 'rubocop'],
)

build_ruby_gem = DDReleaser::Plugins::BuildRubyGem.new(
  gemspec_file_path: 'ddreleaser.gemspec',
)

push_ruby_gem = DDReleaser::Plugins::PushRubyGem.new(
  authorization: 's3333cr33333t',
  gem_name: 'nanoc',
  gem_file_path: 'ddreleaser-*.gem',
)

stages = []
stages << DDReleaser::Stage.new(:test, [test_spec, test_rubocop])
stages << DDReleaser::Stage.new(:build, [build_ruby_gem])
stages << DDReleaser::Stage.new(:publish, [push_ruby_gem])

DDReleaser::Runner.new(stages).run
