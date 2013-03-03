# encoding: utf-8
require 'bundler/setup'
require 'appraisal'
require 'rdoc/task'
require 'rspec/core/rake_task'

Bundler::GemHelper.install_tasks

desc 'Default: run unit specs.'
task :default => :all

desc 'Test formtastic with all supported Rails versions.'
task :all => ["appraisal:install"] do
  exec('rake appraisal spec')
end

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
