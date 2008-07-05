require 'rake'
require 'rake/rdoctask'
require 'spec/rake/spectask'

desc 'Default: run unit specs.'
task :default => :spec

desc 'Test the formtastic plugin.'
Spec::Rake::SpecTask.new('spec') do |t|
  t.spec_files = FileList['spec/**/*_spec.rb']
end

desc 'Generate documentation for the formtastic plugin.'
Rake::RDocTask.new(:rdoc) do |rdoc|
  rdoc.rdoc_dir = 'rdoc'
  rdoc.title    = 'Formtastic'
  rdoc.options << '--line-numbers' << '--inline-source'
  rdoc.rdoc_files.include('README')
  rdoc.rdoc_files.include('lib/**/*.rb')
end
