require File.join(File.dirname(__FILE__), *%w[.. lib formtastic])
require File.join(File.dirname(__FILE__), *%w[.. lib justin_french formtastic])
ActionView::Base.send :include, Formtastic::SemanticFormHelper
