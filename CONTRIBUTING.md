# Contributing

## General Workflow

* Fork the project on Github
* Install development dependencies (`bundle install` and `bundle exec rake appraisal:install`)
* Run the appraisals to check you've got a clean build with passing tests to work on (`bundle exec rake`)
* Create a topic branch for your changes
* Ensure that you provide *documentation* and *test coverage* for your changes (patches won't be accepted without)
* Ensure that all tests still pass (`bundle exec rake`)
* Create a pull request on Github (these are also a great place to start a conversation around a WIP patch as early as possible)


## Continuous Integration

Formtastic supports multiple versions of Rails and Ruby. Here's the approach to managing the complexity:

* The gemspec has a `required_ruby_version` that matches the minimum Ruby version supported by the minimum Rails version we currently support.
* The gemspec has a dependency on `actionpack` matching the minimum Rails version we currently support.
* The gemspec has several development dependencies, but we're not specific about which version. That complexity is handled by Appraisals and/or bundler.
* There is an Appraisal for each of the Rails versions we currently test with (eg Rails 7, 8 and edge) that can name specific versions of these dependencies and developer dependencies as needed.
* Use `bundle exec appraisal` to generate new `gemfiles/*` as needed. We do not check-in the `*.gemfile.lock`, so that each Ruby version in the CI matrix can select an appropriate version of each dependency.
* The GitHub `test.yml` workflow runs a matrix of builds agqainst multiple Ruby and Rails versions, excluding any that don't make sense based on the minimum Ruby version for certain Rails versions.




