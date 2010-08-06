# coding: utf-8
require 'formtastic'
require 'formtastic/layout_helper'
ActionView::Base.send :include, Formtastic::SemanticFormHelper
ActionView::Base.send :include, Formtastic::LayoutHelper
