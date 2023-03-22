# encoding: utf-8
# frozen_string_literal: true
require 'rspec/core'

require 'rspec-dom-testing'

RSpec.configure do |config|
  config.include CustomMacros
  config.include RSpec::Dom::Testing::Matchers
  config.mock_with :rspec

  # rspec-rails 3 will no longer automatically infer an example group's spec type
  # from the file location. You can explicitly opt-in to the feature using this
  # config option.
  # To explicitly tag specs without using automatic inference, set the `:type`
  # metadata manually:
  #
  #     describe ThingsController, :type => :controller do
  #       # Equivalent to being in spec/controllers
  #     end
  config.infer_spec_type_from_file_location!

  # Setting this config option `false` removes rspec-core's monkey patching of the
  # top level methods like `describe`, `shared_examples_for` and `shared_context`
  # on `main` and `Module`. The methods are always available through the `RSpec`
  # module like `RSpec.describe` regardless of this setting.
  # For backwards compatibility this defaults to `true`.
  #
  # https://relishapp.com/rspec/rspec-core/v/3-0/docs/configuration/global-namespace-dsl
  config.expose_dsl_globally = false
end

require "action_controller/railtie"
require 'active_model'

# Create a simple rails application for use in testing the viewhelper
module FormtasticTest
  class Application < Rails::Application
    config.active_support.deprecation = :stderr
    config.secret_key_base = "secret"
    config.eager_load = false
  end
end
FormtasticTest::Application.initialize!

require 'rspec/rails'
