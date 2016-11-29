# Released

Released is an experimental release pipeline tool. It is a possible implementation of [Nanoc RFC 8](https://github.com/nanoc/rfcs/pull/8).

## Example

Example pipeline:

```yaml
stages:
  tested:
    - shell: bundle exec rake spec
    - shell: bundle exec rake rubocop
  packaged:
    - gem_built: nanoc.gemspec
  published:
    - gem_pushed:
        gem_name: nanoc
        authorization: 78f3014a224dfa0cb66a4d60f33f77eada6eb89f
```

Example output:

```
% bundle exec bin/released nanoc.yaml
```

```
*** Assessing goals…

tested:
packaged:
published:
  gem pushed (nanoc)… ok

*** Achieving goals…

tested:
  shell (bundle exec rake spec)… ok
  shell (bundle exec rake rubocop)… ok
packaged:
  gem built (nanoc.gemspec)… ok
published:
  gem pushed (nanoc)… ok

Finished! :)
```

## Philosophy

_Released_’s philosophy is threefold:

* **idempotent**: The tool should be able to be run multiple times for the same version, and steps that have already executed should not cause additional effects. For example, if publishing the gem succeeds, but pushing to GitHub fails, the tool should be able to be run again and pushing to GitHub should succeed without failing on the gem push step.

* **safe**: If an erroneous condition arises, and continuing could lead to a broken release, the tool should abort. For example, if any of the pre-release verifications fail, the release should not continue.

* **resilient**: If a release cannot be made properly due to a dependent service being unavailable, the tool should be able to retry the step, or skip it if the step is deemed to be optional.

## Concepts

_Released_ has the following concepts:

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

When attempting to achieve a goal, _Released_ will first _assess_ the goal in order to determine whether the goal can realistically be obtained given the current circumstances. For example, when the goal is to have a Debian package published, the assessment would fail if no working credentials are available.

_Released_ will take the necessary steps to achieve a given goal, but no more than that. If a goal is already achieved, no steps will be taken. It is therefore quite acceptable try to achieve a goal multiple times.

TODO: figure out difference between temporary/retriable failures (GitHub is down) and permanent/non-retriable ones (tests are failing)

### Stage

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

### Pipeline

A pipeline is a sequence of stages. Each stage will be executed in sequence, and a stage will only be executed if no goals in the previous stage have failed.

## Pipeline file

Strings in `pipeline.yaml` will be replaced according the following rules:

* Strings starting with `env!` will be replaced with the value of the environment variable whose name is everything after the exclamation mark. For example: `version: env!VERSION` will become `version: 0.1.2` if the `VERSION` environment variable is set to `0.1.2`.

* Strings starting with `-----BEGIN PGP MESSAGE-----` will be replaced with their content passed through `gpg --decrypt`.

## Defining custom goal types

To define a custom goal type, subclass `Released::Goal` and give it an identifier:

```ruby
class FileExists < Released::Goal
  identifier :file_exists

  def initialize(config)
    @filename = config.fetch('filename')
    @contents = config.fetch('contents')
  end

  def try_achieve
    File.write(@filename, @contents)
  end

  def achieved?
    File.file?(@filename) && File.read(@filename) == @contents
  end

  def failure_reason
    if !File.file?(@filename)
      "file `#{@filename}` does not exist"
    elsif File.read(@filename) != @contents
      "file `#{@filename}` does not have the expected contents"
    else
      "unknown reason"
    end
  end
end
```

Define the following methods:

* `initialize(config)` — Initialize the goal with the given configuration. The configuration is a hash whose keys are strings (not symbols).

* `try_achieve` — Perform any steps necessary to achieve the goal.

* `achieved?` — Return `true` if the goal has been achieved, `false` otherwise. This method should not mutate state.

* `failure_reason` — Return a string containing the reason why the goal was not achieved. This method should not mutate state.
