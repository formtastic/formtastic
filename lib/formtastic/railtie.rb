require 'formtastic'
require 'formtastic/layout_helper'
require 'rails'

module Formtastic
  class Railtie < Rails::Railtie
    initializer 'formtastic.initialize', :after => :after_initialize do
      ActionView::Base.send :include, Formtastic::SemanticFormHelper
      ActionView::Base.send(:include, Formtastic::LayoutHelper)
    end
  end
end