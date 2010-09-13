# coding: utf-8
require 'rubygems'
require 'rake'
require 'rake/rdoctask'

begin
  gem 'rspec', '>= 1.2.6'
  gem 'rspec-rails', '>= 1.2.6'
  require 'spec'
  require 'spec/rake/spectask'
rescue LoadError
  begin
    require 'rspec/core/rake_task.rb'
    require 'rspec/core/version'
  rescue LoadError
    puts "[formtastic:] RSpec - or one of it's dependencies - is not available. Install it with: sudo gem install rspec-rails"
  end
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

if defined?(RSpec)
  desc 'Test the formtastic plugin.'
  RSpec::Core::RakeTask.new('spec') do |t|
    t.pattern = FileList['spec/**/*_spec.rb']
  end

  desc 'Test the formtastic plugin with specdoc formatting and colors'
  RSpec::Core::RakeTask.new('specdoc') do |t|
    t.pattern = FileList['spec/**/*_spec.rb']
  end

  desc "Run all examples with RCov"
  RSpec::Core::RakeTask.new('examples_with_rcov') do |t|
    t.pattern = FileList['spec/**/*_spec.rb']
    t.rcov = true
    t.rcov_opts = ['--exclude', 'spec,Library']
  end
end
