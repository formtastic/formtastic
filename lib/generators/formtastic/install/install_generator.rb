# coding: utf-8
module Formtastic
  class InstallGenerator < Rails::Generators::Base
    desc "Copies formtastic.css and formtastic_changes.css to public/stylesheets/ and a config initializer to config/initializers/formtastic_config.rb"

    def self.source_root
      # Set source directory for the templates to the rails2 generator template directory
      @source_root ||= File.expand_path(File.join('..', '..', '..', '..', 'generators', 'formtastic', 'templates'), File.dirname(__FILE__))
    end
    
    def self.banner
      "rails generate formtastic:install [options]"
    end

    def copy_files
      empty_directory 'config/initializers'
      template        'formtastic.rb', 'config/initializers/formtastic.rb'

      empty_directory 'public/stylesheets'
      template        'formtastic.css',         'public/stylesheets/formtastic.css'
      template        'formtastic_changes.css', 'public/stylesheets/formtastic_changes.css'
    end
  end
end
