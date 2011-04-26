# encoding: utf-8

Gem::Specification.new do |s|
  s.name = %q{formtastic}
  s.version = "2.0.0.pre"
  s.date = %q{2011-01-07}

  s.required_rubygems_version = Gem::Requirement.new(">= 0") if s.respond_to? :required_rubygems_version=
  s.authors = ["Justin French"]
  s.description = %q{A Rails form builder plugin/gem with semantically rich and accessible markup}
  s.summary = %q{A Rails form builder plugin/gem with semantically rich and accessible markup}
  s.email = %q{justin@indent.com.au}
  s.extra_rdoc_files = ["README.textile"]
  s.files = Dir.glob("lib/**/*") + %w(MIT-LICENSE README.textile)
  s.homepage = %q{http://github.com/justinfrench/formtastic/tree/master}
  s.post_install_message = %q{
  ========================================================================
  Thanks for installing Formtastic!
  ------------------------------------------------------------------------
  You can now (optionally) run the generator to copy some stylesheets and
  a config initializer into your application:
    rails generate formtastic:install

  To generate some semantic form markup for your existing models, just run:
    rails generate formtastic:form MODEL_NAME

  Find out more and get involved:
    http://github.com/justinfrench/formtastic
    http://groups.google.com.au/group/formtastic
    http://twitter.com/formtastic
  ========================================================================
  }
  s.rdoc_options = ["--charset=UTF-8"]
  s.require_paths = ["lib"]
  s.rubygems_version = %q{1.3.6}

  s.add_dependency(%q<rails>, ["~> 3.0"])

  s.add_development_dependency(%q<rspec-rails>, ["~> 2.5"])
  s.add_development_dependency(%q<rspec_tag_matchers>, [">= 1.0.0"])
  s.add_development_dependency(%q<hpricot>, ["~> 0.8.3"])
  s.add_development_dependency(%q<BlueCloth>) # for YARD
  s.add_development_dependency(%q<yard>, ["~> 0.6"])
  s.add_development_dependency(%q<rcov>, ["~> 0.9.9"])
  s.add_development_dependency(%q<colored>)

end
