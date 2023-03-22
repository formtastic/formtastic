# -*- coding: utf-8 -*-
# frozen_string_literal: true
module Formtastic
  module Helpers
    module ActionHelper
      # Renders an action for the form (such as a subit/reset button, or a cancel link).
      #
      # Each action is wrapped in an `<li class="action">` tag with other classes added based on the
      # type of action being rendered, and is intended to be rendered inside a {#buttons}
      # block which wraps the button in a `fieldset` and `ol`.
      #
      # The textual value of the label can be changed from the default through the `:label`
      # argument or through i18n.
      #
      # If using i18n, you'll need to provide the following translations:
      #
      #   en:
      #     formtastic:
      #       actions:
      #         create: "Create new %{model}"
      #         update: "Save %{model}"
      #         cancel: "Cancel"
      #         reset: "Reset form"
      #         submit: "Submit"
      #
      # For forms with an object present, the `update` key will be used if calling `persisted?` on
      # the object returns true (saving changes to a record), otherwise the `create` key will be
      # used. The `submit` key is used as a fallback when there is no object or we cannot determine
      # if `create` or `update` is appropriate.
      #
      # @example Basic usage
      #   # form
      #   <%= semantic_form_for @post do |f| %>
      #     ...
      #     <%= f.actions do %>
      #       <%= f.action :submit %>
      #       <%= f.action :reset %>
      #       <%= f.action :cancel %>
      #     <% end %>
      #   <% end %>
      #
      #   # output
      #   <form ...>
      #     ...
      #     <fieldset class="buttons">
      #       <ol>
      #         <li class="action input_action">
      #           <input name="commit" type="submit" value="Create Post">
      #         </li>
      #         <li class="action input_action">
      #           <input name="commit" type="reset" value="Reset Post">
      #         </li>
      #         <li class="action link_action">
      #           <a href="/posts">Cancel Post</a>
      #         </li>
      #       </ol>
      #     </fieldset>
      #   </form>
      #
      # @example Set the value through the `:label` option
      #   <%= f.action :submit, :label => "Go" %>
      #
      # @example Pass HTML attributes down to the tag inside the wrapper
      #   <%= f.action :submit, :button_html => { :class => 'pretty', :accesskey => 'g', :disable_with => "Wait..." } %>
      #
      # @example Pass HTML attributes down to the `<li>` wrapper
      #   <%= f.action :submit, :wrapper_html => { :class => 'special', :id => 'whatever' } %>
      #
      # @option *args :label [String, Symbol]
      #   Override the label text with a String or a symbold for an i18n translation key
      #
      # @option *args :button_html [Hash]
      #   Override or add to the HTML attributes to be passed down to the `<input>` tag
      #
      # @option *args :wrapper_html [Hash]
      #   Override or add to the HTML attributes to be passed down to the wrapping `<li>` tag
      #
      # @todo document i18n keys
      def action(method, options = {})
        options = options.dup # Allow options to be shared without being tainted by Formtastic
        options[:as] ||= default_action_type(method, options)

        klass = namespaced_action_class(options[:as])

        klass.new(self, template, @object, @object_name, method, options).to_html
      end

      protected

      def default_action_type(method, options = {}) # @private
        case method
          when :submit then :input
          when :reset  then :input
          when :cancel then :link
          else method
        end
      end

      # Takes the `:as` option and attempts to return the corresponding action
      # class. In the case of `:as => :awesome` it will first attempt to find a
      # top level `AwesomeAction` class (to allow the application to subclass
      # and modify to suit), falling back to `Formtastic::Actions::AwesomeAction`.
      #
      # Custom action namespaces to look into can be configured via the
      # {Formtastic::FormBuilder.action_namespaces} configuration setting.
      # @see Helpers::InputHelper#namespaced_input_class
      # @see Formtastic::ActionClassFinder
      def namespaced_action_class(as)
        @action_class_finder ||= action_class_finder.new(self)
        @action_class_finder.find(as)
      rescue Formtastic::ActionClassFinder::NotFoundError => e
        raise Formtastic::UnknownActionError, "Unable to find action #{e.message}"
      end
    end
  end
end
