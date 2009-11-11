# coding: utf-8
require 'rake'
require 'rake/rdoctask'

gem 'rspec-rails', '>= 1.0.0'
require 'spec/rake/spectask'

begin
  GEM = "formtastic"
  AUTHOR = "Justin French"
  EMAIL = "justin@indent.com.au"
  SUMMARY = "A Rails form builder plugin/gem with semantically rich and accessible markup"
  HOMEPAGE = "http://github.com/justinfrench/formtastic/tree/master"
  INSTALL_MESSAGE = %q{
  ========================================================================

  Thanks for installing Formtastic!
    
  You can now (optionally) run the generater to copy some stylesheets and
  a config initializer into your application:
  
    ./script/generate formtastic
    
  The following files will be added:
  
    RAILS_ROOT/public/stylesheets/formtastic.css
    RAILS_ROOT/public/stylesheets/formtastic_changes.css
    RAILS_ROOT/config/initializers/formtastic.rb
  
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
    s.autorequire = GEM
    s.files = %w(MIT-LICENSE README.textile Rakefile) + Dir.glob("{rails,lib,generators,spec}/**/*")
  end
rescue LoadError
  puts "Jeweler, or one of its dependencies, is not available. Install it with: sudo gem install technicalpickles-jeweler -s http://gems.github.com"
end

desc 'Default: run unit specs.'
task :default => :spec

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

desc 'Generate documentation for the formtastic plugin.'
Rake::RDocTask.new(:rdoc) do |rdoc|
  rdoc.rdoc_dir = 'rdoc'
  rdoc.title    = 'Formtastic'
  rdoc.options << '--line-numbers' << '--inline-source'
  rdoc.rdoc_files.include('README.textile')
  rdoc.rdoc_files.include('lib/**/*.rb')
end

desc "Run all examples with RCov"
Spec::Rake::SpecTask.new('examples_with_rcov') do |t|
  t.spec_files = FileList['spec/**/*_spec.rb']
  t.rcov = true
  t.rcov_opts = ['--exclude', 'spec,Library']
end
