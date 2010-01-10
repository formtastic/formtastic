# coding: utf-8
require File.join(File.dirname(__FILE__), *%w[.. lib formtastic])
require File.join(File.dirname(__FILE__), *%w[.. lib formtastic layout_helper])
ActionView::Base.send :include, Formtastic::SemanticFormHelper
ActionView::Base.send :include, Formtastic::LayoutHelper
