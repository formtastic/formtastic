appraise 'rails-3.2' do
  gem 'rails', '~> 3.2.0'
  gem 'test-unit-minitest', :platform => [:ruby_22, :ruby_23]
end

appraise 'rails-4' do
  gem 'rails', '~> 4.0.0'
end

# Special case for a change in I18n
appraise 'rails-4.0.4' do
  gem 'rails', '4.0.4'
end

appraise 'rails-4.1' do
  gem 'rails', '~>4.1.0'
end

appraise 'rails-4.2' do
  gem 'rails', '~>4.2.0.beta4'
end

appraise 'rails-edge' do
  gem 'rails', :git => 'git://github.com/rails/rails.git'
  gem 'rack', :github => 'rack/rack'
  gem 'i18n', :github => 'svenfuchs/i18n'
  gem 'arel', :github => 'rails/arel'
  gem 'rspec-rails', :github => 'rspec/rspec-rails'
  gem 'rspec-mocks', :github => 'rspec/rspec-mocks'
  gem 'rspec-support', :github => 'rspec/rspec-support'
  gem 'rspec-core', :github => 'rspec/rspec-core'
  gem 'rspec-expectations', :github => 'rspec/rspec-expectations'
end
