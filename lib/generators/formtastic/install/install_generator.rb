# encoding: utf-8
module Formtastic
  class InstallGenerator < Rails::Generators::Base
    desc "Copies formtastic.css and formtastic_changes.css to public/stylesheets/ and a config initializer to config/initializers/formtastic_config.rb"

    source_root File.expand_path('../../../templates', __FILE__)

    def copy_files
      template        'formtastic.rb', 'config/initializers/formtastic.rb'

      template        'formtastic.css',         'public/stylesheets/formtastic.css'
      template        'formtastic_changes.css', 'public/stylesheets/formtastic_changes.css'
    end
  end
end
