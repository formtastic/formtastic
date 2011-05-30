# Configure Rails 3.1 to have assert_select_jquery() in tests
module Formtastic
  # Required for formtastic.css to be discoverable in the asset pipeline
  # @private
  class Engine < ::Rails::Engine
  end
end