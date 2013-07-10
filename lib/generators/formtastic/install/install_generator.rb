# encoding: utf-8

module Formtastic
  # Copies formtastic.css to public/stylesheets/ (Rails 3.0.x only) and a config initializer
  # to config/initializers/formtastic.rb (all Rails versions).
  #
  # @example
  #   $ rails generate formtastic:install
  class InstallGenerator < Rails::Generators::Base
    source_root File.expand_path('../../../templates', __FILE__)
    class_option :template_engine

    desc "Copies a config initializer to config/initializers/formtastic.rb"
    def copy_files
      copy_file 'formtastic.rb', 'config/initializers/formtastic.rb'
    end

    def copy_scaffold_template
      engine = options[:template_engine]
      copy_file "_form.html.#{engine}", "lib/templates/#{engine}/scaffold/_form.html.#{engine}"
    end
  end
end
