# coding: utf-8
# Get current OS - needed for clipboard functionality
case RUBY_PLATFORM
when /darwin/ then
  CURRENT_OS = :osx
when /win32/
  CURRENT_OS = :win
  begin
    require 'win32/clipboard'
  rescue LoadError
    # Do nothing
  end
else
  CURRENT_OS = :x
end

class FormGenerator < Rails::Generator::NamedBase
  
  default_options :haml => false,
                  :partial => false
  
  VIEWS_PATH = File.join('app', 'views').freeze
  IGNORED_COLUMNS = [:updated_at, :created_at].freeze
  
  attr_reader   :controller_file_name,
                :controller_class_path,
                :controller_class_nesting,
                :controller_class_nesting_depth,
                :controller_class_name,
                :template_type
                
  def initialize(runtime_args, runtime_options = {})
    super
    base_name, @controller_class_path = extract_modules(@name.pluralize)
    controller_class_name_without_nesting, @controller_file_name = inflect_names(base_name)
    @template_type = options[:haml] ? :haml : :erb
  end
  
  def manifest
    record do |m|
      if options[:partial]
        # Ensure directory exists.
        m.directory File.join(VIEWS_PATH, controller_class_path, controller_file_name)
        # Create a form partial for the model as "_form" in it's views path.
        m.template "view__form.html.#{template_type}", File.join(VIEWS_PATH, controller_file_name, "_form.html.#{template_type}")
      else
        # Load template file, and render without saving to file
        template = File.read(File.join(source_root, "view__form.html.#{template_type}"))
        erb = ERB.new(template, nil, '-')
        generated_code = erb.result(binding).strip rescue nil
        
        # Print the result, and copy to clipboard
        puts "# ---------------------------------------------------------"
        puts "#  GENERATED FORMTASTIC CODE"
        puts "# ---------------------------------------------------------"
        puts
        puts generated_code || " Nothing could be generated - model exists?"
        puts
        puts "# ---------------------------------------------------------"
        puts " Copied to clipboard - just paste it!" if save_to_clipboard(generated_code)
      end
    end
  end
  
  protected
    
    # Save to lipboard with multiple OS support.
    def save_to_clipboard(data)
      return unless data
      begin
        case CURRENT_OS
        when :osx
          `echo "#{data}" | pbcopy`
        when :win
          ::Win32::Clipboard.data = data
        else # :linux/:unix
          `echo "#{data}" | xsel --clipboard` || `echo "#{data}" | xclip`
        end
      rescue
        false
      else
        true
      end
    end
    
    # Add additional model attributes if specified in args - probably not that common scenario.
    def attributes
      # Get columns for the requested model
      existing_attributes = @class_name.constantize.content_columns.reject { |column| IGNORED_COLUMNS.include?(column.name.to_sym) }
      @args = super + existing_attributes
    end
    
    def add_options!(opt)
      opt.separator ''
      opt.separator 'Options:'
      
      # Allow option to generate HAML views instead of ERB.
      opt.on('--haml',
        "Generate HAML output instead of the default ERB.") do |v|
        options[:haml] = v
      end
      
      # Allow option to generate to partial in model's views path, instead of printing out in terminal.
      opt.on('--partial',
        "Save generated output directly to a form partial (app/views/{resource}/_form.html.*).") do |v|
        options[:partial] = v
      end
    end
    
    def banner
      "Usage: #{$0} form ExistingModelName [--haml] [--partial]"
    end
    
end