# encoding: utf-8
require 'rubygems'
require 'rake'
require 'rake/rdoctask'
require 'rspec/core/rake_task'
require 'tasks/verify_rcov'
require 'bundler'

Bundler::GemHelper.install_tasks

desc 'Default: run unit specs.'
task :default => :spec_and_verify_coverage

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

desc 'Test the formtastic inputs.'
RSpec::Core::RakeTask.new('spec:inputs') do |t|
  t.pattern = FileList['spec/inputs/*_spec.rb']
end

desc 'Test the formtastic plugin with specdoc formatting and colors'
RSpec::Core::RakeTask.new('specdoc') do |t|
  t.pattern = FileList['spec/**/*_spec.rb']
end

desc 'Run all examples with RCov'
RSpec::Core::RakeTask.new('rcov') do |t|
  t.pattern = FileList['spec/**/*_spec.rb']
  t.rcov = true
  t.rcov_opts = %w(--exclude gems/*,spec/*,.bundle/*, --aggregate coverage.data)
end

RCov::VerifyTask.new(:verify_coverage) do |t|
  t.require_exact_threshold = false
  t.threshold = (RUBY_VERSION == "1.8.7" ? 95 : 0)
end

desc "Run all examples and verify coverage"
task :spec_and_verify_coverage => [:rcov, :verify_coverage] do
end
