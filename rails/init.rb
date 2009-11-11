# coding: utf-8
require File.join(File.dirname(__FILE__), *%w[.. lib formtastic])
ActionView::Base.send :include, Formtastic::SemanticFormHelper
