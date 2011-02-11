# encoding: utf-8
require 'rubygems'
require 'rake'
require 'rake/rdoctask'
require 'rspec/core/rake_task'

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

desc 'Test the formtastic plugin.'
RSpec::Core::RakeTask.new('spec') do |t|
  t.pattern = FileList['spec/**/*_spec.rb']
end

desc 'Test the formtastic plugin with specdoc formatting and colors'
RSpec::Core::RakeTask.new('specdoc') do |t|
  t.pattern = FileList['spec/**/*_spec.rb']
end

desc 'Run all examples with RCov'
RSpec::Core::RakeTask.new('examples_with_rcov') do |t|
  t.pattern = FileList['spec/**/*_spec.rb']
  t.rcov = true
  t.rcov_opts = ['--exclude', 'spec,Library']
end
