class FormtasticStylesheetsGenerator < Rails::Generator::Base
  
  def initialize(*runtime_args)
    puts %q{
===================================================
Please run `./script/generate formtastic` instead.
===================================================
  }
  end
  
  def manifest
    record do |m|
    end
  end
  
end