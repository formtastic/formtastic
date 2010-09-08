# coding: utf-8
module Formtastic
  class FormGenerator < Rails::Generators::NamedBase
    desc "Generates formtastic form code based on an existing model. By default the " <<
         "generated code will be printed out directly in the terminal, and also copied " <<
         "to clipboard. Can optionally be saved into partial directly."

    argument :name, :type => :string, :required => true, :banner => 'ExistingModelName'
    argument :attributes, :type => :array, :default => [], :banner => 'field:type field:type'

    class_option :haml, :type => :boolean, :default => false, :group => :formtastic,
                 :desc => "Generate HAML instead of ERB"

    class_option :partial, :type => :boolean, :default => false, :group => :formtastic,
                 :desc => 'Generate a form partial in the model views path, i.e. "_form.html.erb" or "_form.html.haml"'

    class_option :controller, :type => :string, :default => false, :group => :formtastic,
                 :desc => 'Generate for custom controller/view path - in case model and controller namespace is different, i.e. "admin/posts"'

    def self.source_root
     # Set source directory for the templates to the rails2 generator template directory
     @source_root ||= File.expand_path(File.join('..', '..', '..', '..', 'generators', 'form', 'templates'), File.dirname(__FILE__))
    end

    def create_or_show
      @attributes = self.columns if @attributes.empty?
      if options[:partial]
        empty_directory "app/views/#{controller_path}"
        template "view__form.html.#{template_type}", "app/views/#{controller_path}/_form.html.#{template_type}"
      else
        template = File.read("#{self.class.source_root}/view__form.html.#{template_type}")
        erb = ERB.new(template, nil, '-')
        generated_code = erb.result(binding).strip rescue nil

        puts "# ---------------------------------------------------------"
        puts "#  GENERATED FORMTASTIC CODE"
        puts "# ---------------------------------------------------------"
        puts
        puts generated_code || "Nothing could be generated - model exists?"
        puts
        puts "# ---------------------------------------------------------"
        puts "Copied to clipboard - just paste it!" if save_to_clipboard(generated_code)
      end
    end

    protected

    IGNORED_COLUMNS = [:updated_at, :created_at].freeze

    def template_type
      @template_type ||= options[:haml] ? :haml : :erb
    end

    def controller_path
      @controller_path ||= if options[:controller]
        options[:controller].underscore
      else
        name.underscore.pluralize
      end
    end

    def columns
      @columns ||= self.name.camelize.constantize.content_columns.reject { |column| IGNORED_COLUMNS.include?(column.name.to_sym) }
    end

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
  end
end
