# coding: utf-8
require 'rake'
require 'rake/rdoctask'

begin
  require 'spec/rake/spectask'
rescue LoadError
  begin
    gem 'rspec-rails', '>= 1.0.0'
    require 'spec/rake/spectask'
  rescue LoadError
    puts "[formtastic:] RSpec - or one of it's dependencies - is not available. Install it with: sudo gem install rspec-rails"
  end
end

begin
  GEM = "formtastic"
  AUTHOR = "Justin French"
  EMAIL = "justin@indent.com.au"
  SUMMARY = "A Rails form builder plugin/gem with semantically rich and accessible markup"
  HOMEPAGE = "http://github.com/justinfrench/formtastic/tree/master"
  INSTALL_MESSAGE = %q{
  ========================================================================
  Thanks for installing Formtastic!
  ------------------------------------------------------------------------
  You can now (optionally) run the generator to copy some stylesheets and
  a config initializer into your application:
    ./script/generate formtastic

  To generate some semantic form markup for your existing models, just run:
    ./script/generate form MODEL_NAME

  Find out more and get involved:
    http://github.com/justinfrench/formtastic
    http://groups.google.com.au/group/formtastic
  ========================================================================
  }
  
  gem 'jeweler', '>= 1.0.0'
  require 'jeweler'
  
  Jeweler::Tasks.new do |s|
    s.name = GEM
    s.summary = SUMMARY
    s.email = EMAIL
    s.homepage = HOMEPAGE
    s.description = SUMMARY
    s.author = AUTHOR
    s.post_install_message = INSTALL_MESSAGE
    
    s.require_path = 'lib'
    s.files = %w(MIT-LICENSE README.textile Rakefile) + Dir.glob("{rails,lib,generators,spec}/**/*")
    
    # Runtime dependencies: When installing Formtastic these will be checked if they are installed.
    # Will be offered to install these if they are not already installed.
    s.add_dependency 'activesupport', '>= 2.3.0'
    s.add_dependency 'actionpack', '>= 2.3.0'
    
    # Development dependencies. Not installed by default.
    # Install with: sudo gem install formtastic --development
    s.add_development_dependency 'rspec-rails', '>= 1.2.6'
    s.add_development_dependency 'rspec_tag_matchers', '>= 1.0.0'
  end
  
  Jeweler::GemcutterTasks.new
rescue LoadError
  puts "[formtastic:] Jeweler - or one of its dependencies - is not available. Install it with: sudo gem install jeweler -s http://gemcutter.org"
end

desc 'Default: run unit specs.'
task :default => :spec

desc 'Generate documentation for the formtastic plugin.'
Rake::RDocTask.new(:rdoc) do |rdoc|
  rdoc.rdoc_dir = 'rdoc'
  rdoc.title    = 'Formtastic'
  rdoc.options << '--line-numbers' << '--inline-source'
  rdoc.rdoc_files.include('README.textile')
  rdoc.rdoc_files.include('lib/**/*.rb')
end

if defined?(Spec)
  desc 'Test the formtastic plugin.'
  Spec::Rake::SpecTask.new('spec') do |t|
    t.spec_files = FileList['spec/**/*_spec.rb']
    t.spec_opts = ["-c"]
  end

  desc 'Test the formtastic plugin with specdoc formatting and colors'
  Spec::Rake::SpecTask.new('specdoc') do |t|
    t.spec_files = FileList['spec/**/*_spec.rb']
    t.spec_opts = ["--format specdoc", "-c"]
  end

  desc "Run all examples with RCov"
  Spec::Rake::SpecTask.new('examples_with_rcov') do |t|
    t.spec_files = FileList['spec/**/*_spec.rb']
    t.rcov = true
    t.rcov_opts = ['--exclude', 'spec,Library']
  end
end
