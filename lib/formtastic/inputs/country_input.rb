require 'inputs/base'

module Formtastic
  module Inputs
    module CountryInput
      include Formtastic::Inputs::Base
      
      # Outputs a country select input, wrapping around a regular country_select helper.
      # Rails doesn't come with a country_select helper by default any more, so you'll need to install
      # the "official" plugin, or, if you wish, any other country_select plugin that behaves in the
      # same way.
      #
      # The Rails plugin iso-3166-country-select plugin can be found "here":http://github.com/rails/iso-3166-country-select.
      #
      # By default, Formtastic includes a handfull of english-speaking countries as "priority counties",
      # which you can change to suit your market and user base (see README for more info on config).
      #
      # Examples:
      #   f.input :location, :as => :country # use Formtastic::SemanticFormBuilder.priority_countries array for the priority countries
      #   f.input :location, :as => :country, :priority_countries => /Australia/ # set your own
      #
      def country_input(method, options)
        raise "To use the :country input, please install a country_select plugin, like this one: http://github.com/rails/iso-3166-country-select" unless respond_to?(:country_select)
  
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