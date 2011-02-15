require 'inputs/base'

module Formtastic
  module Inputs
    # Boolean inputs are used to render an input for a single checkbox, typically for attributes
    # with a simple yes/no or true/false value. Boolean inputs are used by default for boolean
    # database columns.
    #
    # @example Full form context and markup
    #   <%= semantic_form_for @post %>
    #     <%= f.inputs do %>
    #       <%= f.input :published, :as => :boolean %>
    #     <% end %>
    #   <% end %>
    #   
    #   <form...>
    #     <fieldset>
    #       <ol>
    #         <li class="boolean" id="post_published_input">
    #           <input type="hidden" name="post[published]" id="post_published" value="0">
    #           <label for="post_published">
    #             <input type="checkbox" name="post[published]" id="post_published" value="1">
    #             Published?
    #           </label>
    #         </li>
    #       </ol>
    #     </fieldset>
    #   </form>
    #
    # @example Set the values for the checked and unchecked states
    #   <%= f.input :published, :checked_value => "yes", :unchecked_value => "no" %> 
    #
    # @see Formtastic::Helpers::InputsHelper#input InputsHelper#input for full documetation of all possible options.
    module BooleanInput
      include Formtastic::Inputs::Base
      
      def boolean_input(method, options)
        html_options  = options.delete(:input_html) || {}
        checked_value = options.delete(:checked_value) || '1'
        unchecked_value = options.delete(:unchecked_value) || '0'
        checked = @object && ActionView::Helpers::InstanceTag.check_box_checked?(@object.send(:"#{method}"), checked_value)
  
        html_options[:id] = html_options[:id] || generate_html_id(method, "")
        input = template.check_box_tag(
          "#{@object_name}[#{method}]",
          checked_value,
          checked,
          html_options
        )
        
        options = options_for_label(options)
        options[:for] ||= html_options[:id]
  
        # the label() method will insert this nested input into the label at the last minute
        options[:label_prefix_for_nested_input] = input
  
        template.hidden_field_tag((html_options[:name] || "#{@object_name}[#{method}]"), unchecked_value, :id => nil) << label(method, options)
      end
    end
  end
end