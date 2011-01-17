require 'support/base'
require 'formtastic/reflection'

module Formtastic
  module Inputs
    module SelectInput
      include Support::Base
      include Formtastic::Reflection
      
      # Outputs a label and a select box containing options from the parent
      # (belongs_to, has_many, has_and_belongs_to_many) association. If an association
      # is has_many or has_and_belongs_to_many the select box will be set as multi-select
      # and size = 5
      #
      # Example (belongs_to):
      #
      #   f.input :author
      #
      #   <label for="book_author_id">Author</label>
      #   <select id="book_author_id" name="book[author_id]">
      #     <option value=""></option>
      #     <option value="1">Justin French</option>
      #     <option value="2">Jane Doe</option>
      #   </select>
      #
      # Example (has_many):
      #
      #   f.input :chapters
      #
      #   <label for="book_chapter_ids">Chapters</label>
      #   <select id="book_chapter_ids" name="book[chapter_ids]">
      #     <option value=""></option>
      #     <option value="1">Chapter 1</option>
      #     <option value="2">Chapter 2</option>
      #   </select>
      #
      # Example (has_and_belongs_to_many):
      #
      #   f.input :authors
      #
      #   <label for="book_author_ids">Authors</label>
      #   <select id="book_author_ids" name="book[author_ids]">
      #     <option value=""></option>
      #     <option value="1">Justin French</option>
      #     <option value="2">Jane Doe</option>
      #   </select>
      #
      #
      # You can customize the options available in the select by passing in a collection. A collection can be given
      # as an Array, a Hash or as a String (containing pre-rendered HTML options). If not provided, the choices are
      # found by inferring the parent's class name from the method name and simply calling all on it
      # (VehicleOwner.all in the example above).
      #
      # Examples:
      #
      #   f.input :author, :collection => @authors
      #   f.input :author, :collection => Author.all
      #   f.input :author, :collection => [@justin, @kate]
      #   f.input :author, :collection => {@justin.name => @justin.id, @kate.name => @kate.id}
      #   f.input :author, :collection => ["Justin", "Kate", "Amelia", "Gus", "Meg"]
      #   f.input :author, :collection => grouped_options_for_select(["North America",[["United States","US"],["Canada","CA"]]])
      #
      # The :label_method option allows you to customize the text label inside each option tag two ways:
      #
      # * by naming the correct method to call on each object in the collection as a symbol (:name, :login, etc)
      # * by passing a Proc that will be called on each object in the collection, allowing you to use helpers or multiple model attributes together
      #
      # Examples:
      #
      #   f.input :author, :label_method => :full_name
      #   f.input :author, :label_method => :login
      #   f.input :author, :label_method => :full_name_with_post_count
      #   f.input :author, :label_method => Proc.new { |a| "#{a.name} (#{pluralize("post", a.posts.count)})" }
      #
      # The :value_method option provides the same customization of the value attribute of each option tag.
      #
      # Examples:
      #
      #   f.input :author, :value_method => :full_name
      #   f.input :author, :value_method => :login
      #   f.input :author, :value_method => Proc.new { |a| "author_#{a.login}" }
      #
      # You can pass html_options to the select tag using :input_html => {}
      #
      # Examples:
      #
      #   f.input :authors, :input_html => {:size => 20, :multiple => true}
      #
      # By default, all select inputs will have a blank option at the top of the list. You can add
      # a prompt with the :prompt option, or disable the blank option with :include_blank => false.
      #
      #
      # You can group the options in optgroup elements by passing the :group_by option
      # (Note: only tested for belongs_to relations)
      #
      # Examples:
      #
      #   f.input :author, :group_by => :continent
      #
      # All the other options should work as expected. If you want to call a custom method on the
      # group item. You can include the option:group_label_method
      # Examples:
      #
      #   f.input :author, :group_by => :continents, :group_label_method => :something_different
      def select_input(method, options)
        html_options = options.delete(:input_html) || {}
        html_options[:multiple] = html_options[:multiple] || options.delete(:multiple)
        html_options.delete(:multiple) if html_options[:multiple].nil?
  
        reflection = reflection_for(method)
        if reflection && [ :has_many, :has_and_belongs_to_many ].include?(reflection.macro)
          html_options[:multiple] = true if html_options[:multiple].nil?
          html_options[:size]     ||= 5
          options[:include_blank] ||= false
        end
        options = set_include_blank(options)
        input_name = generate_association_input_name(method)
        html_options[:id] ||= generate_html_id(input_name, "")
  
        select_html = if options[:group_by]
          # The grouped_options_select is a bit counter intuitive and not optimised (mostly due to ActiveRecord).
          # The formtastic user however shouldn't notice this too much.
          raw_collection = find_raw_collection_for_column(method, options.reverse_merge(:find_options => { :include => options[:group_by] }))
          label, value = detect_label_and_value_method!(raw_collection, options)
          group_collection = raw_collection.map { |option| option.send(options[:group_by]) }.uniq
          group_label_method = options[:group_label_method] || detect_label_method(group_collection)
          group_collection = group_collection.sort_by { |group_item| group_item.send(group_label_method) }
          group_association = options[:group_association] || detect_group_association(method, options[:group_by])
  
          # Here comes the monster with 8 arguments
          grouped_collection_select(input_name, group_collection,
                                         group_association, group_label_method,
                                         value, label,
                                         strip_formtastic_options(options), html_options)
        else
          collection = find_collection_for_column(method, options)
  
          select(input_name, collection, strip_formtastic_options(options), html_options)
        end
  
        label_options = options_for_label(options).merge(:input_name => input_name)
        label_options[:for] ||= html_options[:id]
        label(method, label_options) << select_html
      end
      
      protected
      
      # As #find_collection_for_column but returns the collection without mapping the label and value
      #
      def find_raw_collection_for_column(column, options) #:nodoc:
        collection = if options[:collection]
          options.delete(:collection)
        elsif reflection = reflection_for(column)
          options[:find_options] ||= {}
  
          if conditions = reflection.options[:conditions]
            if reflection.klass.respond_to?(:merge_conditions)
              options[:find_options][:conditions] = reflection.klass.merge_conditions(conditions, options[:find_options][:conditions])
              reflection.klass.all(options[:find_options])
            else
              reflection.klass.where(conditions).where(options[:find_options][:conditions])
            end
          else
            reflection.klass.all(options[:find_options])
          end
        else
          create_boolean_collection(options)
        end
  
        collection = collection.to_a if collection.is_a?(Hash)
        collection
      end
      
      # Returns a hash to be used by radio and select inputs when a boolean field
      # is provided.
      #
      def create_boolean_collection(options) #:nodoc:
        options[:true] ||= ::Formtastic::I18n.t(:yes)
        options[:false] ||= ::Formtastic::I18n.t(:no)
        options[:value_as_class] = true unless options.key?(:value_as_class)
  
        [ [ options.delete(:true), true], [ options.delete(:false), false ] ]
      end
      
      # Return the label collection method when none is supplied using the
      # values set in collection_label_methods.
      #
      def detect_label_method(collection) #:nodoc:
        detect_label_and_value_method!(collection).first
      end
      
      # Detects the method to call for fetching group members from the groups when grouping select options
      #
      def detect_group_association(method, group_by)
        object_to_method_reflection = reflection_for(method)
        method_class = object_to_method_reflection.klass
  
        method_to_group_association = method_class.reflect_on_association(group_by)
        group_class = method_to_group_association.klass
  
        # This will return in the normal case
        return method.to_s.pluralize.to_sym if group_class.reflect_on_association(method.to_s.pluralize)
  
        # This is for belongs_to associations named differently than their class
        # form.input :parent, :group_by => :customer
        # eg.
        # class Project
        #   belongs_to :parent, :class_name => 'Project', :foreign_key => 'parent_id'
        #   belongs_to :customer
        # end
        # class Customer
        #   has_many :projects
        # end
        group_method = method_class.to_s.underscore.pluralize.to_sym
        return group_method if group_class.reflect_on_association(group_method) # :projects
  
        # This is for has_many associations named differently than their class
        # eg.
        # class Project
        #   belongs_to :parent, :class_name => 'Project', :foreign_key => 'parent_id'
        #   belongs_to :customer
        # end
        # class Customer
        #   has_many :tasks, :class_name => 'Project', :foreign_key => 'customer_id'
        # end
        possible_associations =  group_class.reflect_on_all_associations(:has_many).find_all{|assoc| assoc.klass == object_class}
        return possible_associations.first.name.to_sym if possible_associations.count == 1
  
        raise "Cannot infer group association for #{method} grouped by #{group_by}, there were #{possible_associations.empty? ? 'no' : possible_associations.size} possible associations. Please specify using :group_association"
  
      end
  
    end
  end
end