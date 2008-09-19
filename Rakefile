require 'rake'
require 'rake/rdoctask'
require 'spec/rake/spectask'

desc 'Default: run unit specs.'
task :default => :spec

desc 'Test the formtastic plugin.'
Spec::Rake::SpecTask.new('spec') do |t|
  t.spec_files = FileList['spec/**/*_spec.rb']
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
  rdoc.rdoc_files.include('README')
  rdoc.rdoc_files.include('lib/**/*.rb')
end

