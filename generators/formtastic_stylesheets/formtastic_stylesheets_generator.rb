class FormtasticStylesheetsGenerator < Rails::Generator::Base
  
  def initialize(*runtime_args)
    super
  end
  
  def manifest
    record do |m|
      m.directory File.join('public', 'stylesheets')
      m.template 'formtastic.css',   File.join('public', 'stylesheets', 'formtastic.css')
    end
  end
  
  protected
  
  def banner
    %{Usage: #{$0} #{spec.name}\nCopies vendor/plugins/formtastic/generators/formtastic_stylesheets/templates/formtastic.css to public/formtastic.css}
  end
  
end