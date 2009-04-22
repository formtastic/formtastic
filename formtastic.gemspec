# -*- encoding: utf-8 -*-

Gem::Specification.new do |s|
  s.name = %q{formtastic}
  s.version = "0.1.7"

  s.required_rubygems_version = Gem::Requirement.new(">= 0") if s.respond_to? :required_rubygems_version=
  s.authors = ["Justin French"]
  s.autorequire = %q{formtastic}
  s.date = %q{2009-04-22}
  s.description = %q{A Rails form builder plugin/gem with semantically rich and accessible markup}
  s.email = %q{justin@indent.com.au}
  s.extra_rdoc_files = ["README.textile"]
  s.files = ["MIT-LICENSE", "README.textile", "Rakefile", "rails/init.rb", "lib/formtastic.rb", "lib/justin_french", "lib/justin_french/formtastic.rb", "lib/locale", "lib/locale/en.yml", "generators/formtastic_stylesheets", "generators/formtastic_stylesheets/formtastic_stylesheets_generator.rb", "generators/formtastic_stylesheets/templates", "generators/formtastic_stylesheets/templates/formtastic.css", "generators/formtastic_stylesheets/templates/formtastic_changes.css", "spec/formtastic_spec.rb", "spec/test_helper.rb"]
  s.has_rdoc = true
  s.homepage = %q{http://github.com/justinfrench/formtastic/tree/master}
  s.rdoc_options = ["--inline-source", "--charset=UTF-8"]
  s.require_paths = ["lib"]
  s.rubygems_version = %q{1.3.1}
  s.summary = %q{A Rails form builder plugin/gem with semantically rich and accessible markup}

  if s.respond_to? :specification_version then
    current_version = Gem::Specification::CURRENT_SPECIFICATION_VERSION
    s.specification_version = 2

    if Gem::Version.new(Gem::RubyGemsVersion) >= Gem::Version.new('1.2.0') then
    else
    end
  else
  end
end
