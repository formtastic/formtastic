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
      rails_version >= Gem::Version.new("3.0.0") && 
      rails_version < Gem::Version.new("4.0.0")
    end

    def rails4?
      rails_version >= Gem::Version.new("4.0.0") && 
      rails_version < Gem::Version.new("5.0.0")
    end
    
    def rails4_0?
      rails_version >= Gem::Version.new("4.0.0") && 
      rails_version < Gem::Version.new("4.1.0")
    end

    def rails4_1?
      rails_version >= Gem::Version.new("4.1.0") && 
      rails_version < Gem::Version.new("4.2.0")
    end
    
    def deprecated_version_of_rails?
      rails_version < Gem::Version.new("4.0.4")
    end

    def rails_version
      Gem::Version.new(::Rails::VERSION::STRING)
    end

  end
end
