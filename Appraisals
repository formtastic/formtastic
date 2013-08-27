appraise 'rails-3.0' do
  gem 'rails',      '~> 3.0.0'
end

appraise 'rails-3.1' do
  gem 'rails',      '~> 3.1.0'
end

appraise 'rails-3.2' do
  gem 'rails',      '~> 3.2.0'
end

appraise 'rails-4' do
  gem 'rails', '~> 4.0.0'
end

if ENV["RAILS_EDGE"] == "true"
  appraise 'rails-edge' do
    gem 'rails', :git => 'git://github.com/rails/rails.git'
  end
end
