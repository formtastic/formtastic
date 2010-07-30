if Formtastic::Util.rails3?
  gem 'rspec', '~> 2.0.0.beta19'
  gem 'rspec-rails', '~> 2.0.0.beta19'
  gem 'rspec_tag_matchers'
  gem 'i18n', '>= 0.4.0'

  require "rubygems"
  require "action_controller/railtie"
  require "active_resource/railtie"
  require 'active_model'
  require 'rspec/core'
  require 'rspec/rails'
  require 'rspec_tag_matchers'

  # Create a simple rails application for use in testing the viewhelper
  module FormtasticTest
    class Application < Rails::Application
      # Configure the default encoding used in templates for Ruby 1.9.
      config.encoding = "utf-8"
      config.active_support.deprecation = :stderr
    end
  end
  FormtasticTest::Application.initialize!

  # Configure RSpec 2.0
  RSpec.configure do |config|
    config.include RspecTagMatchers
    config.include CustomMacros
    config.mock_with :rspec
  end

else
  gem 'rspec', '>= 1.2.6'
  gem 'rspec-rails', '>= 1.2.6'
  gem 'rspec_tag_matchers'
  gem 'hpricot', '>= 0.6.1'
  gem 'i18n', '< 0.4.0'

  require 'rspec_tag_matchers'

  Spec::Runner.configure do |config|
    config.include(RspecTagMatchers)
    config.include(CustomMacros)
  end
end  