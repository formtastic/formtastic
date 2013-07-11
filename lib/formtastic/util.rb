# encoding: utf-8

# Adapted from the rails3 compatibility shim in Haml 2.2
module Formtastic
  # @private
  module Util
    extend self
    ## Rails XSS Safety

    # Returns the given text, marked as being HTML-safe.
    # With older versions of the Rails XSS-safety mechanism,
    # this destructively modifies the HTML-safety of `text`.
    #
    # @param text [String]
    # @return [String] `text`, marked as HTML-safe
    def html_safe(text)
      if text.respond_to?(:html_safe)
        text.html_safe
      else
        text
      end
    end
    
    def rails3?
      ::Rails::VERSION::MAJOR == 3
    end
    
    def rails4_0?
      ::Rails::VERSION::MAJOR == 4 && ::Rails::VERSION::MINOR == 0
    end
    
    def deprecated_version_of_rails?
      const_defined?(:Rails) && ::Rails::VERSION::MAJOR == 3 && ::Rails::VERSION::MINOR < 2
    end

  end
end
