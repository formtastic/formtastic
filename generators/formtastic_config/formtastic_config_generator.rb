class FormtasticConfigGenerator < Rails::Generator::Base
  
  def initialize(*runtime_args)
    super
  end
  
  def manifest
    record do |m|
      m.directory File.join('config', 'initializers')
      m.template 'formtastic.rb',   File.join('config', 'initializers', 'formtastic.rb')
    end
  end
  
  protected
  
  def banner
    %{Usage: #{$0} #{spec.name}\nCopies a (commented out) sample Formtastic config file into config/initializers/formtastic.rb}
  end
  
end