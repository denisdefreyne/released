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

Example output:

```
% bundle exec bin/ddreleaser ddreleaser.yaml
```

```
*** Assessing goals…

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

## Concepts

A goal can be

* _assessed_, in order to figure out whether it is achievable. For example, assessing might include checking access credentials necessary for the goal to be achieved.

* _achieved_, which means that all tasks necessary to complete the goal have been completed, and no further work is necessary.

* _failed_, if the goal could not be achieved. This could be due to temporary failure (e.g. network problems when uploading an asset), or permanent failure (the asset is already published but is not the same as the one that is to be published).
