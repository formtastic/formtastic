require 'formtastic'
require 'rails'

module Formtastic
  class Railtie < Rails::Railtie
    initializer :after_initialize do
      ActionView::Base.send :include, Formtastic::SemanticFormHelper
    end
  end
end