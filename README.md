# DDReleaser

An experiment in writing a release pipeline for Nanoc. It is a possible implementation of [Nanoc RFC 8](https://github.com/nanoc/rfcs/pull/8).

## Example

Example pipeline:

```yaml
stages:
  test:
    - shell: bundle exec rake spec
    - shell: bundle exec rake rubocop
  package:
    - gem_built: ddreleaser.gemspec
  publish:
    - gem_pushed:
        gem_file_path: ddreleaser-*.gem
        gem_name: ddreleaser
        authorization: n0p3z
```

Example ouput:

```
% bundle exec bin/ddreleaser ddreleaser.yaml
```

```
*** assessing goals…

test:
package:
publish:
  gem pushed (nanoc)… ok

*** Achieving goals…

test:
  shell (bundle exec rake spec)… ok
  shell (bundle exec rake rubocop)… ok
package:
  gem built (ddreleaser.gemspec)… ok
publish:
  gem pushed (nanoc)… ok

Finished! :)
```
