# encoding: utf-8
require 'formtastic'
require 'formtastic/helpers/layout_helper'
ActionView::Base.send :include, Formtastic::SemanticFormHelper
ActionView::Base.send :include, Formtastic::Helpers::LayoutHelper
