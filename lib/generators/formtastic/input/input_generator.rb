# frozen_string_literal: true
module Formtastic

  # Modify existing inputs, subclass them, or create your own from scratch.
  # @example
  # !!!shell
  #   $ rails generate formtastic:input HatSize

  # @example Define input name using underscore convention
  # !!!shell
  #   $ rails generate formtastic:input hat_size

  # @example Override an existing input behavior
  # !!!shell
  #   $ rails generate formtastic:input string --extend

  # @example Extend an existing input behavior
  # !!!shell
  #   $ rails generate formtastic:input FlexibleText --extend string
  class InputGenerator < Rails::Generators::NamedBase

    argument :name, :type => :string, :required => true, :banner => 'FILE_NAME'

    source_root File.expand_path('../../../templates', __FILE__)

    class_option :extend

    def create
      normalize_file_name
      define_extension_sentence
      template "input.rb", "app/inputs/#{name.underscore}_input.rb"
    end

    protected

    def normalize_file_name
      name.chomp!("Input")  if name.ends_with?("Input")
      name.chomp!("_input") if name.ends_with?("_input")
      name.chomp!("input")  if name.ends_with?("input")
    end

    def define_extension_sentence
      @extension_sentence = "< Formtastic::Inputs::#{name.camelize}Input" if options[:extend] == "extend"
      @extension_sentence ||= "< Formtastic::Inputs::#{options[:extend].camelize}Input" if options[:extend]
    end
  end
end