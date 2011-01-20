# encoding: utf-8

require 'formtastic'
require 'rails'

module Formtastic
  # @private
  class Railtie < Rails::Railtie
    initializer 'formtastic.initialize', :after => :after_initialize do
      ActionView::Base.send :include, Formtastic::Helpers::FormHelper
    end
  end
end
