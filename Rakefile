# encoding: utf-8
require 'bundler/setup'
require 'yard'
require 'rspec/core/rake_task'

Bundler::GemHelper.install_tasks

desc 'Default: run unit specs.'
if !ENV["APPRAISAL_INITIALIZED"] && !ENV["TRAVIS"]
  task :default => :appraisal
else
  task :default => :spec
end

desc 'Run the default task over all gemfiles.'
task :appraisal do
  for_all_gemfiles("exec", "rake")
end

namespace :appraisal do
  desc 'Run `bundle install` over all gemfiles.'
  task :install do
    for_all_gemfiles("install")
  end
end

def for_all_gemfiles(*args)
  Dir.glob("gemfiles/*/Gemfile").sort.each do |gemfile|
    Bundler.with_original_env do
      sh({ "APPRAISAL_INITIALIZED" => "true", "BUNDLE_GEMFILE" => gemfile }, "bundle", *args)
    end
  end
end

desc 'Generate documentation for the formtastic plugin.'
YARD::Rake::YardocTask.new(:yard) do |t|

end
task doc: :yard

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
