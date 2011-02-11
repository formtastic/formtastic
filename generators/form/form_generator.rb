# encoding: utf-8

class FormGenerator < Rails::Generator::NamedBase

  default_options :haml => false,
                  :partial => false

  VIEWS_PATH = File.join('app', 'views').freeze
  IGNORED_COLUMNS = [:updated_at, :created_at].freeze

  attr_reader :controller_file_name,
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
        controller_and_view_path = options[:controller] || File.join(controller_class_path, controller_file_name)
        # Ensure directory exists.
        m.directory File.join(VIEWS_PATH, controller_and_view_path)
        # Create a form partial for the model as "_form" in it's views path.
        m.template "_form.html.#{template_type}", File.join(VIEWS_PATH, controller_and_view_path, "_form.html.#{template_type}")
      else
        # Load template file, and render without saving to file
        template = File.read(File.join(source_root, "_form.html.#{template_type}"))
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
        puts "Copied to clipboard - just paste it!" if save_to_clipboard(generated_code)
      end
    end
  end

  protected

    def save_to_clipboard(data)
      return unless data

      begin
        case RUBY_PLATFORM
        when /win32/
          require 'win32/clipboard'
          ::Win32::Clipboard.data = data
        when /darwin/ # mac
          `echo "#{data}" | pbcopy`
        else # linux/unix
          `echo "#{data}" | xsel --clipboard` || `echo "#{data}" | xclip`
        end
      rescue LoadError
        false
      else
        true
      end
    end

    # Add additional model attributes if specified in args - probably not that common scenario.
    def attributes
      # Get columns for the requested model.
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

      opt.on('--controller CONTROLLER_PATH',
        "Specify a non-standard controller for the specified model (e.g. admin/posts).") do |v|
        options[:controller] = v if v.present?
      end
    end

    def banner
      "Usage: #{$0} form ExistingModelName [--haml] [--partial]"
    end
    
    def source_root
      File.expand_path('../../../lib/generators/templates/rails2', __FILE__)
    end

end
