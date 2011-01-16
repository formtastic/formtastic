# encoding: utf-8
require File.join(File.dirname(__FILE__), *%w[formtastic i18n])
require File.join(File.dirname(__FILE__), *%w[formtastic util])
require File.join(File.dirname(__FILE__), *%w[formtastic railtie]) if defined?(::Rails::Railtie)
require File.join(File.dirname(__FILE__), *%w[formtastic builder base])
require File.join(File.dirname(__FILE__), *%w[formtastic helpers form_helper])
