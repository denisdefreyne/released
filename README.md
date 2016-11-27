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
          gem_name: ddreleaser
          authorization: n0p3z
```

Example ouput:

```
% bundle exec bin/ddreleaser ddreleaser.yaml
*** Running pre-checks…

test:
package:
publish:
  push gem… ok

*** Running…

test:
  run specs… ok
  check style… ok
package:
  build gem… ok
publish:
  push gem… ok

Finished! :)
```
