# encoding: utf-8

require 'formtastic'
require 'rails'

module Formtastic
  # @private
  class Railtie < Rails::Railtie
    initializer 'formtastic.initialize' do
      ActiveSupport.on_load(:action_view) do
        include Formtastic::Helpers::FormHelper
      end
    end
  end
end
