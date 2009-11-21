module Formtastic
  module I18n
    
    DEFAULT_SCOPE = [:formtastic].freeze
    DEFAULT_VALUES = {
        :required       => 'required',
        :yes            => 'Yes',
        :no             => 'No',
        :create         => 'Create {{model}}',
        :update         => 'Update {{model}}'
      }.freeze
    
    class << self
      
      def translate(*args)
        key = args.shift.to_sym
        options = args.extract_options!
        options.reverse_merge!(:default => DEFAULT_VALUES[key])
        options[:scope] = [DEFAULT_SCOPE, options[:scope]].flatten.compact
        ::I18n.translate(key, *(args << options))
      end
      alias :t :translate
      
    end
    
  end
end