require_relative 'lib/released/version'

Gem::Specification.new do |s|
  s.name        = 'released'
  s.version     = Released::VERSION
  s.homepage    = 'https://github.com/ddfreyne/released'
  s.summary     = 'extensible release tool'
  s.description = ''

  s.author  = 'Denis Defreyne'
  s.email   = 'denis.defreyne@stoneship.org'
  s.license = 'MIT'

  s.files =
    Dir['[A-Z]*'] +
    Dir['{lib,spec}/**/*'] +
    Dir['*.gemspec']
  s.require_paths      = ['lib']

  s.rdoc_options     = ['--main', 'README.md']

  s.required_ruby_version = '>= 2.3.0'

  # Dependencies for goals
  # TODO: Move into plugins
  s.add_runtime_dependency('twitter')
  s.add_runtime_dependency('gems')
  s.add_runtime_dependency('netrc')
  s.add_runtime_dependency('octokit')

  # TODO: Remove this (copy piper?)
  s.add_runtime_dependency('nanoc', '~> 4.4')

  s.add_runtime_dependency('ddplugin', '~> 1.0')

  s.add_development_dependency('bundler', '>= 1.7.10', '< 2.0')
end
