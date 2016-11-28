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
    - gem_built: nanoc.gemspec
  publish:
    - gem_pushed:
        gem_name: nanoc
        authorization: 78f3014a224dfa0cb66a4d60f33f77eada6eb89f
```

Example output:

```
% bundle exec bin/ddreleaser nanoc.yaml
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
  gem built (nanoc.gemspec)… ok
publish:
  gem pushed (nanoc)… ok

Finished! :)
```

## Concepts

DDReleaser has the following concepts:

* pipeline
* stage
* goal

The sections below elaborate on these concepts.

### Goal

A goal expresses an individual desired end state. For example:

* `tests_passing`: the tests are passing
* `style_checked`: the style checks are passing
* `pkg_built`: the Debian package is built
* `pkg_published`: the Debian package is published
* `tweet_sent`: the tweet about the release is sent

Goals are described in a passive voice (e.g. `gem_built`; “the gem has been built”) rather than in the imperative mood (e.g. `build_gem`; “build the gem”). This approach allows expressing what the end state is, rather than how to achieve it. This way, the release process is idempotent: re-running the release process when it has already succeeded before will leave everything as-is, as all goals have already been achieved.

When attempting to achieve a goal, DDReleaser will first _assess_ the goal in order to determine whether the goal can realistically be obtained given the current circumstances. For example, when the goal is to have a Debian package published, the assessment would fail if no working credentials are available.

DDReleaser will take the necessary steps to achieve a given goal, but no more than that. If a goal is already achieved, no steps will be taken. It is therefore quite acceptable try to achieve a goal multiple times.

TODO: figure out difference between temporary/retriable failures (GitHub is down) and permanent/non-retriable ones (tests are failing)

## Stage

A stage consists of one or more goals. A stage is completed when each of the individual goals inside that stage are achieved.

For example:

* `tested`
  * `tests_passing`: the tests are passing
  * `style_checked`: the style checks are passing
* `built`:
  * `pkg_built`: the Debian package is built
  * `gem_built`: the RubyGem is built
* `published`:
  * `pkg_published`: the Debian package is published
  * `gem_published`: the RubyGem is published

The goals inside a stage can be executed in parallel or in any order.

## Pipeline

A pipeline is a sequence of stages. Each stage will be executed in sequence, and a stage will only be executed if no goals in the previous stage have failed.
