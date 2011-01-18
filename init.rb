# encoding: utf-8
require 'formtastic'
require 'formtastic/helpers/layout_helper'
ActionView::Base.send :include, Formtastic::Helpers::FormHelper
ActionView::Base.send :include, Formtastic::Helpers::LayoutHelper
