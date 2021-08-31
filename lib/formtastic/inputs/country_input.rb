# frozen_string_literal: true
module Formtastic
  module Inputs
    # Outputs a country select input, wrapping around a regular country_select helper.
    # Rails doesn't come with a `country_select` helper by default any more, so you'll need to do
    # one of the following:
    #
    # * install the [country_select](https://github.com/stefanpenner/country_select) gem
    # * install any other country_select plugin that behaves in a similar way
    # * roll your own `country_select` helper with the same args and options as the Rails one
    #
    # Formtastic supports both 1.x and 2.x of stefanpenner/country_select, but if you're upgrading
    # from 1.x, they behave quite differently, so please see their [upgrade instructions](https://github.com/stefanpenner/country_select/blob/master/UPGRADING.md).
    #
    # By default, Formtastic includes a handful of English-speaking countries as "priority
    # countries", which can be set in the `priority_countries` configuration array in the
    # formtastic.rb initializer to suit your market and user base (see README for more info on
    # configuration). Additionally, it is possible to set the :priority_countries on a per-input
    # basis through the `:priority_countries` option. These priority countries will be passed down
    # to the `country_select` helper of your choice, and may or may not be used by the helper.
    #
    # @example Basic example with full form context using `priority_countries` from config
    #
    #   <%= semantic_form_for @user do |f| %>
    #     <%= f.inputs do %>
    #       <%= f.input :nationality, :as => :country %>
    #     <% end %>
    #   <% end %>
    #
    #   <li class='country'>
    #     <label for="user_nationality">Country</label>
    #     <select id="user_nationality" name="user[nationality]">
    #       <option value="...">...</option>
    #       # ...
    #   </li>
    #
    # @example `:priority_countries` set on a specific input (country_select 1.x)
    #
    #   <%= semantic_form_for @user do |f| %>
    #     <%= f.inputs do %>
    #       <%= f.input :nationality, :as => :country, :priority_countries => ["Australia", "New Zealand"] %>
    #     <% end %>
    #   <% end %>
    #
    #   <li class='country'>
    #     <label for="user_nationality">Country</label>
    #     <select id="user_nationality" name="user[nationality]">
    #       <option value="...">...</option>
    #       # ...
    #   </li>
    #
    # @example `:priority_countries` set on a specific input (country_select 2.x)
    #
    #   <%= semantic_form_for @user do |f| %>
    #     <%= f.inputs do %>
    #       <%= f.input :nationality, :as => :country, :priority_countries => ["AU", "NZ"] %>
    #     <% end %>
    #   <% end %>
    #
    #   <li class='country'>
    #     <label for="user_nationality">Country</label>
    #     <select id="user_nationality" name="user[nationality]">
    #       <option value="...">...</option>
    #       # ...
    #   </li>
    #
    # @see Formtastic::Helpers::InputsHelper#input InputsHelper#input for full documentation of all possible options.
    class CountryInput 
      include Base

      CountrySelectPluginMissing = Class.new(StandardError)

      def to_html
        raise CountrySelectPluginMissing, "To use the :country input, please install a country_select plugin, like this one: https://github.com/stefanpenner/country_select" unless builder.respond_to?(:country_select)
        input_wrapping do
          label_html <<
          builder.country_select(method, priority_countries, input_options, input_html_options)
        end
      end
      
      def priority_countries
        options[:priority_countries] || builder.priority_countries
      end

    end
  end
end
