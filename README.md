# DDReleaser

An experiment in writing a release pipeline for Nanoc. It is a possible implementation of [Nanoc RFC 8](https://github.com/nanoc/rfcs/pull/8).

## Example

Example pipeline:

```yaml
stages:
  - name: test
    steps:
      - name: run specs
        shell: bundle exec rake spec
      - name: check style
        shell: bundle exec rake rubocop
  - name: package
    steps:
      - name: build gem
        gem_build: ddreleaser.gemspec
  - name: publish
    steps:
      - name: push gem
        gem_push:
          gem_file_path: ddreleaser-*.gem
          gem_name: nanoc
          authorization: n0p3z
```

Example ouput:

```
% bundle exec bin/ddreleaser nanoc.yaml
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
