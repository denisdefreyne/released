# DDReleaser

An experiment in writing a release pipeline for Nanoc. It is a possible implementation of [Nanoc RFC 8](https://github.com/nanoc/rfcs/pull/8).

## Example

```
% bundle exec bin/release nanoc.yaml
*** Running pre-checks…

stage: test
stage: build
stage: publish
  step: DDReleaser::Plugins::PushRubyGem(gem_name = nanoc)… ok

*** Running…

stage: test
  step: DDReleaser::Plugins::Shell(command = bundle exec rake spec)… ok
  step: DDReleaser::Plugins::Shell(command = bundle exec rake rubocop)… ok
stage: build
  step: DDReleaser::Plugins::BuildRubyGem(gemspec_file_path = ddreleaser.gemspec)… ok
stage: publish
  step: DDReleaser::Plugins::PushRubyGem(gem_name = nanoc)… ok

Finished! :)
```
