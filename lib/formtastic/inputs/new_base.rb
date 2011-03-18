require 'inputs/new_base/associations'
require 'inputs/new_base/fileish'
require 'inputs/new_base/validations'
require 'inputs/new_base/naming'
require 'inputs/new_base/hints'
require 'inputs/new_base/errors'
require 'inputs/new_base/database'
require 'inputs/new_base/options'
require 'inputs/new_base/html'
require 'inputs/new_base/labelling'

module Formtastic
  module Inputs
    module NewBase
      
      attr_accessor :builder, :template, :object, :object_name, :method, :options
      
      def initialize(builder, template, object, object_name, method, options)
        @builder = builder
        @template = template
        @object = object
        @object_name = object_name
        @method = method
        @options = options.dup
      end
      
      include Html
      include Options
      include Database
      include Errors
      include Hints
      include Naming
      include Validations
      include Fileish
      include Associations
      include Labelling
      
    end
  end
end
  