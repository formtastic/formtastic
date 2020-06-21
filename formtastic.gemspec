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

  s.required_ruby_version = '>= 2.4.0'
  s.required_rubygems_version = Gem::Requirement.new(">= 0") if s.respond_to? :required_rubygems_version=
  s.rubygems_version = %q{1.3.6}

  s.add_dependency(%q<actionpack>, [">= 5.2.0"])

  s.add_development_dependency(%q<rspec-rails>, ["~> 3.4"])
  s.add_development_dependency(%q<rspec-dom-testing>, [">= 0.1.0"])
  s.add_development_dependency(%q<yard>, ["~> 0.9.20"])
  s.add_development_dependency(%q<ammeter>, ["~> 1.1.3"])
  s.add_development_dependency(%q<rake>)
  s.add_development_dependency(%q<sqlite3>, ["~> 1.4"])
end
