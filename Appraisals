appraise 'rails-3.2' do
  gem 'rails', '~> 3.2.0'
  gem 'test-unit-minitest', :platform => [:ruby_22, :ruby_23]
  gem 'nokogiri', '~>1.6.8', platform: :mri_20
end

appraise 'rails-4' do
  gem 'rails', '~> 4.0.0'
  gem 'nokogiri', '~>1.6.8', platform: :mri_20
end

# Special case for a change in I18n
appraise 'rails-4.0.4' do
  gem 'rails', '4.0.4'
  gem 'nokogiri', '~>1.6.8', platform: :mri_20
end

appraise 'rails-4.1' do
  gem 'rails', '~>4.1.0'
  gem 'nokogiri', '~>1.6.8', platform: :mri_20
end

appraise 'rails-4.2' do
  gem 'rails', '~>4.2.0'
  gem 'nokogiri', '~>1.6.8', platform: :mri_20
end

appraise 'rails-5.0' do
  gem 'rails', '~> 5.0.1'
  gem 'rspec-rails', '~> 3.5'
end

appraise 'rails-edge' do
  gem 'rails', github: 'rails/rails'
  gem 'rack', github: 'rack/rack'
  gem 'i18n', github: 'svenfuchs/i18n'
  gem 'arel', github: 'rails/arel'
  gem 'rspec-rails', github: 'rspec/rspec-rails'
  gem 'rspec-mocks', github: 'rspec/rspec-mocks'
  gem 'rspec-support', github: 'rspec/rspec-support'
  gem 'rspec-core', github: 'rspec/rspec-core'
  gem 'rspec-expectations', github: 'rspec/rspec-expectations'
end
