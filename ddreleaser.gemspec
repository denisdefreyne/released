require_relative 'lib/ddreleaser/version'

Gem::Specification.new do |s|
  s.name        = 'ddreleaser'
  s.version     = DDReleaser::VERSION
  s.homepage    = 'http://nanoc.ws/'
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

  s.add_runtime_dependency('ddplugin', '~> 0.1')
  s.add_runtime_dependency('nanoc', '~> 4.4') # for piper
  s.add_development_dependency('bundler', '>= 1.7.10', '< 2.0')
end
