# encoding: utf-8

# Adapted from the rails3 compatibility shim in Haml 2.2
module Formtastic
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
      return text if text.nil?
      return text.html_safe
      text
    end
  end
end
