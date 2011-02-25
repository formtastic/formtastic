module Formtastic
  module Inputs
    # @private
    module Basic

      def basic_input_helper(form_helper_method, type, method, options) #:nodoc:
        html_options = options.delete(:input_html) || {}
        html_options = default_string_options(method, type).merge(html_options) if [:numeric, :string, :password, :text, :phone, :search, :url, :email].include?(type)
        field_id = generate_html_id(method, "")
        html_options[:id] ||= field_id
        label_options = options_for_label(options)
        label_options[:for] ||= html_options[:id]
        label(method, label_options) <<
          send(respond_to?(form_helper_method) ? form_helper_method : :text_field, method, html_options)
      end

      protected

      # Generates default_string_options by retrieving column information from
      # the database.
      #
      def default_string_options(method, type) #:nodoc:
        def get_maxlength_for(method)
          validation = validations_for(method).find do |validation|
            (validation.respond_to?(:macro) && validation.macro == :validates_length_of) || # Rails 2 + 3 style validation
            (validation.respond_to?(:kind) && validation.kind == :length) # Rails 3 style validator
          end

          if validation
            validation.options[:maximum] || (validation.options[:within].present? ? validation.options[:within].max : nil)
          else
            nil
          end
        end

        validation_max_limit = get_maxlength_for(method)
        column = column_for(method)

        if type == :text
          { :rows => default_text_area_height,
            :cols => default_text_area_width }
        elsif type == :numeric || column.nil? || !column.respond_to?(:limit) || column.limit.nil?
          { :maxlength => validation_max_limit,
            :size => default_text_field_size }
        else
          { :maxlength => validation_max_limit || column.limit,
            :size => default_text_field_size }
        end
      end

      # Returns the active validations for the given method or an empty Array if no validations are
      # found for the method.
      #
      # By default, the if/unless options of the validations are evaluated and only the validations
      # that should be run for the current object state are returned. Pass :all to the last
      # parameter to return :all validations regardless of if/unless options.
      #
      # Requires the ValidationReflection plugin to be present or an ActiveModel. Returns an epmty
      # Array if neither is the case.
      #
      def validations_for(method, mode = :active)
        # ActiveModel?
        validations = if @object && @object.class.respond_to?(:validators_on)
          @object.class.validators_on(method)
        else
          # ValidationReflection plugin?
          if @object && @object.class.respond_to?(:reflect_on_validations_for)
            @object.class.reflect_on_validations_for(method)
          else
            []
          end
        end

        validations = validations.select do |validation|
          (validation.options.present? ? options_require_validation?(validation.options) : true)
        end unless mode == :all

        return validations
      end

    end
  end
end