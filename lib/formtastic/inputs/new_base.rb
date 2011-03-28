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
      
      extend ActiveSupport::Autoload
      
      autoload :Associations
      autoload :Collections
      autoload :Database
      autoload :Errors
      autoload :Fileish
      autoload :GroupedCollections
      autoload :Hints
      autoload :Html
      autoload :Labelling
      autoload :Naming
      autoload :Options
      autoload :Stringish
      autoload :Timeish
      autoload :Validations
      
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
  