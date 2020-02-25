appraise 'rails-4.2' do
  gem 'rails', '~>4.2.0'
  gem 'nokogiri', '~>1.6.8', platform: :mri_20
end

appraise 'rails-5.0' do
  gem 'rails', '~> 5.0.1'
end

appraise 'rails-5.1' do
  gem 'rails', '~> 5.1.0'
end

appraise 'rails-5.2' do
  gem 'rails', '~> 5.2.0'
end

appraise 'rails-edge' do
  git_source(:github) { |repo| "https://github.com/#{repo}.git" }

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
