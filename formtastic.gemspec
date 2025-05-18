# encoding: utf-8
$:.push File.expand_path("../lib", __FILE__)
require "formtastic/version"

Gem::Specification.new do |s|
  s.name        = %q{formtastic}
  s.version     = Formtastic::VERSION
  s.platform    = Gem::Platform::RUBY
  s.authors     = [%q{Justin French}]
  s.email       = [%q{justin@indent.com.au}]
  s.homepage    = %q{http://github.com/formtastic/formtastic}
  s.summary     = %q{A Rails form builder plugin/gem with semantically rich and accessible markup}
  s.description = %q{A Rails form builder plugin/gem with semantically rich and accessible markup}
  s.license     = 'MIT'

  s.files         = `git ls-files`.split("\n")
  s.test_files    = `git ls-files -- {test,spec,features}/*`.split("\n")
  s.executables   = []
  s.require_paths = ["lib"]

  s.rdoc_options = ["--charset=UTF-8"]
  s.extra_rdoc_files = ["README.md"]

  # Minimum Ruby version is probably the same as whatever the minimum Rails version currently expects.
  s.required_ruby_version = '>= 2.7.0'

  # Minimum Ruby Gems version also matches whatever the minimum Rails version currently expects.
  s.required_rubygems_version = ">= 1.8.11"

  # User dependency is really just Rails, where we want describe the minimum version we support,
  # which is probably the oldest version that hasn't reached end-of-life for security updates.
  s.add_dependency(%q<actionpack>, [">= 7.1.0"])

  # Development dependencies (for people working on Formtastic) are different to the minimum support
  # version. Here we can expect a more modern stack with the latest Rails major version at a minimum,
  # along with modern and compatible versions of the associated development tools. We also be more
  # specific about the version numbers, because this isn't where we worry about backwards compatibilty
  # or edge compatibiluty -- the appraisal gem files cover that.
  s.add_development_dependency(%q<activesupport>, ["~> 8.0.2"])
  s.add_development_dependency(%q<activerecord>, ["~> 8.0.2"])

  s.add_development_dependency(%q<rspec-rails>, [">= 4.0"])
  s.add_development_dependency(%q<rspec-dom-testing>, [">= 0.1.0"])
  s.add_development_dependency(%q<rspec-mocks>, ["~> 3.12.2"])

  s.add_development_dependency(%q<yard>, ["~> 0.9.20"])
  s.add_development_dependency(%q<ammeter>, ["~> 1.1.3"])
  s.add_development_dependency(%q<rake>)
  s.add_development_dependency(%q<sqlite3>, ["~> 2.6.0"])
end
