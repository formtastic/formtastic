# encoding: utf-8
module Formtastic
  # Generates a Formtastic form partial based on an existing model. It will not overwrite existing
  # files without confirmation.
  #
  # @example
  #   $ rails generate formtastic:form Post
  # @example Copy the partial code to the pasteboard rather than generating a partial
  #   $ rails generate formtastic:form Post --copy
  # @example Return HAML output instead of ERB
  #   $ rails generate formtastic:form Post --haml
  # @example Generate a form for specific model attributes
  #   $ rails generate formtastic:form Post title:string body:text
  # @example Generate a form for a specific controller
  #   $ rails generate formtastic:form Post --controller admin/posts
  class FormGenerator < Rails::Generators::NamedBase
    desc "Generates a Formtastic form partial based on an existing model."

    argument :name, :type => :string, :required => true, :banner => 'MyExistingModel'
    argument :attributes, :type => :array, :default => [], :banner => 'attribute attribute'

    class_option :haml, :type => :boolean, :default => false, :group => :formtastic,
                 :desc => "Generate HAML instead of ERB"

    class_option :partial, :type => :boolean, :default => true, :group => :formtastic,
                 :desc => 'Generate a form partial in the model views path (eg `posts/_form.html.erb`)'

    class_option :copy, :type => :boolean, :default => false, :group => :formtastic,
                 :desc => 'Copy the generated code the clipboard instead of generating a partial file."'

    class_option :controller, :type => :string, :default => false, :group => :formtastic,
                 :desc => 'Generate for custom controller/view path - in case model and controller namespace is different, i.e. "admin/posts"'

    source_root File.expand_path('../../../templates', __FILE__)

    def create_or_show
      @attributes = reflected_attributes if @attributes.empty?
      
      if options[:copy]
        template = File.read("#{self.class.source_root}/_form.html.#{template_type}")
        erb = ERB.new(template, nil, '-')
        generated_code = erb.result(binding).strip rescue nil
        puts "The following code has been to the clipboard, just paste it in your views:" if save_to_clipboard(generated_code)
        puts generated_code || "Error: Nothing generated. Does the model exist?"
      else
        empty_directory "app/views/#{controller_path}"
        template "_form.html.#{template_type}", "app/views/#{controller_path}/_form.html.#{template_type}"
      end
    end

    protected

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

    def reflected_attributes
      columns = model.content_columns.map{|column| column.name}
      columns += model.reflect_on_all_associations.map{|association| association.name.to_s}
      columns -= %w(created_at updated_at)
    end

    def model
      @model ||= name.camelize.constantize
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
