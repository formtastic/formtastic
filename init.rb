require File.join(File.dirname(__FILE__), 'lib', 'justin_french', 'formtastic')
ActionView::Base.send :include, JustinFrench::Formtastic::SemanticFormHelper
