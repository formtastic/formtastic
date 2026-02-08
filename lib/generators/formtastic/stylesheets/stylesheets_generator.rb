module Formtastic
  # Copies a stylesheet into to app/assets/stylesheets/formtastic.css
  #
  # @example
  # !!!shell
  #   $ rails generate formtastic:stylesheets
  class StylesheetsGenerator < Rails::Generators::Base
    source_root File.expand_path("../../../templates", __FILE__)

    desc "Copies Formtastic example stylesheet into your app"
    def copy_files
      copy_file "formtastic.css", "app/assets/stylesheets/formtastic.css"
    end
  end
end
