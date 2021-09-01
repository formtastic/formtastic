# frozen_string_literal: true
module Formtastic
  module Inputs
    module Base
      module DatetimePickerish
        include Base::Placeholder
      
        def html_input_type
          raise NotImplementedError
        end
      
        def default_size
          raise NotImplementedError
        end
        
        def value
          raise NotImplementedError
        end
      
        def input_html_options
          super.merge(extra_input_html_options)
        end
      
        def extra_input_html_options
          {
            :type => html_input_type, 
            :size => size, 
            :maxlength => maxlength, 
            :step => step,
            :value => value
          }
        end
      
        def size
          return options[:size] if options.key?(:size)
          return options[:input_html][:size] if options[:input_html] && options[:input_html].key?(:size)
          default_size
        end
      
        def step
          return step_from_macro(options[:input_html][:step]) if options[:input_html] && options[:input_html][:step] && options[:input_html][:step].is_a?(Symbol)
          return options[:input_html][:step] if options[:input_html] && options[:input_html].key?(:step)
          default_step
        end
      
        def maxlength
          return options[:maxlength] if options.key?(:maxlength)
          return options[:input_html][:maxlength] if options[:input_html] && options[:input_html].key?(:maxlength)
          default_size
        end
      
        def default_maxlength
          default_size
        end
      
        def default_step
          1
        end
        
        protected
        
        def step_from_macro(sym)
          case sym

            # date
            when :day then "1"
            when :seven_days, :week then "7"
            when :two_weeks, :fortnight then "14"
            when :four_weeks then "28"
            when :thirty_days then "30"

            # time
            when :second then "1"
            when :minute then "60"
            when :fifteen_minutes, :quarter_hour then "900"
            when :thirty_minutes, :half_hour then "1800"
            when :sixty_minutes, :hour then "3600"            

            else sym
          end
        end
        
      end
    end
  end
end