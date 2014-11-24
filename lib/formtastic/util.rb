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
      match?(rails_version, "~> 3.0")
    end

    def rails4?
      match?(rails_version, "~> 4.0")
    end

    def rails4_0?
      match?(rails_version, "~> 4.0.0")
    end

    def rails4_1?
      match?(rails_version, "~> 4.1.0")
    end

    def deprecated_version_of_rails?
      match?(rails_version, "< #{minimum_version_of_rails}")
    end

    def minimum_version_of_rails
      "4.1.0"
    end

    def rails_version
      ::Rails::VERSION::STRING
    end

    def match?(version, dependency)
      Gem::Dependency.new("formtastic", dependency).match?("formtastic", version)
    end

  end
end
