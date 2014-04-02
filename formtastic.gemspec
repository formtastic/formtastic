# encoding: utf-8
$:.push File.expand_path("../lib", __FILE__)
require "formtastic/version"

Gem::Specification.new do |s|
  s.name        = %q{formtastic}
  s.version     = Formtastic::VERSION
  s.platform    = Gem::Platform::RUBY
  s.authors     = [%q{Justin French}]
  s.email       = [%q{justin@indent.com.au}]
  s.homepage    = %q{http://github.com/justinfrench/formtastic}
  s.summary     = %q{A Rails form builder plugin/gem with semantically rich and accessible markup}
  s.description = %q{A Rails form builder plugin/gem with semantically rich and accessible markup}
  s.license     = 'MIT'

  s.files         = `git ls-files`.split("\n")
  s.test_files    = `git ls-files -- {test,spec,features}/*`.split("\n")
  s.executables   = `git ls-files -- bin/*`.split("\n").map{ |f| File.basename(f) }
  s.require_paths = ["lib"]

  s.rdoc_options = ["--charset=UTF-8"]
  s.extra_rdoc_files = ["README.textile"]

  s.required_rubygems_version = Gem::Requirement.new(">= 0") if s.respond_to? :required_rubygems_version=
  s.rubygems_version = %q{1.3.6}

  s.add_dependency(%q<actionpack>, [">= 3.0"])

  s.add_development_dependency(%q<nokogiri>, ["< 1.6.0"]) # 1.6 requires Ruby 1.9.2, drop in v3.0
  s.add_development_dependency(%q<rspec-rails>, ["~> 2.14.0"])
  s.add_development_dependency(%q<rspec_tag_matchers>, [">= 1.0.0"])
  s.add_development_dependency(%q<hpricot>, ["~> 0.8.3"])
  s.add_development_dependency(%q<BlueCloth>) # for YARD
  s.add_development_dependency(%q<yard>, ["~> 0.6"])
  s.add_development_dependency(%q<colored>)
  s.add_development_dependency(%q<tzinfo>)
  s.add_development_dependency(%q<ammeter>, ["0.2.5"])
  s.add_development_dependency(%q<appraisal>, ["1.0.0.beta3"])
  s.add_development_dependency(%q<rake>, ["<= 10.1.1"]) # Anything higher requires Ruby 1.9, drop in v3.0
  s.add_development_dependency(%q<activemodel>)
end
