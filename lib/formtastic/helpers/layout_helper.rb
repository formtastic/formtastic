# encoding: utf-8

module Formtastic
  module Helpers
    module LayoutHelper
    
      def formtastic_stylesheet_link_tag
        stylesheet_link_tag("formtastic") +
        stylesheet_link_tag("formtastic_changes")
      end
    
    end
  end
end
