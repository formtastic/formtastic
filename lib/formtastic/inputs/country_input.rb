module Formtastic
  module Inputs
    # Outputs a country select input, wrapping around a regular country_select helper.
    # Rails doesn't come with a `country_select` helper by default any more, so you'll need to do
    # one of the following:
    #
    # * install [the official Rails plugin](http://github.com/rails/iso-3166-country-select)
    # * install any other country_select plugin that behaves in a similar way
    # * roll your own `country_select` helper with the same args and options as the Rails one
    #
    # By default, Formtastic includes a handfull of English-speaking countries as "priority
    # counties", which can be set in the `priority_countries` configuration array in the
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
    # @example `:priority_countries` set on a specific input
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
    # @see Formtastic::Helpers::InputsHelper#input InputsHelper#input for full documetation of all possible options.
    module CountryInput
      include Formtastic::Inputs::Base

      def country_input(method, options)
        raise "To use the :country input, please install a country_select plugin, like this one: https://github.com/chrislerum/country_select" unless respond_to?(:country_select)

        html_options = options.delete(:input_html) || {}
        priority_countries = options.delete(:priority_countries) || self.priority_countries

        field_id = generate_html_id(method, "")
        html_options[:id] ||= field_id
        label_options = options_for_label(options)
        label_options[:for] ||= html_options[:id]

        label(method, label_options) <<
        country_select(method, priority_countries, strip_formtastic_options(options), html_options)
      end
    end
  end
end