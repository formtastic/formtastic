require 'reflection'

module Formtastic
  module Inputs
    # A select input is used to render a `<select>` tag with a series of options to choose from. 
    # It works for both single selections (like a `belongs_to` relationship, or "yes/no" boolean),
    # as well as multiple selections (like a `has_and_belongs_to_many`/`has_many` relationship, 
    # for assigning many genres to a song, for example).
    #
    # This is the default input choice when:
    #
    # * the database column type is an `:integer` and there is an association (`belongs_to`)
    # * the database column type is a `:string` and the `:collection` option is used
    # * there an object with an association, but no database column on the object (`has_many`, etc)
    # * there is no object and the `:collection` option is used
    #
    # The flexibility of the `:collection` option (see examples) makes the :select input viable as
    # an alternative for many other input types. For example, instead of...
    #
    # * a `:string` input (where you want to force the user to choose from a few specific strings rather than entering anything)
    # * a `:boolean` checkbox input (where the user could choose yes or no, rather than checking a box)
    # * a `:date`, `:time` or `:datetime` input (where the user could choose from pre-selected dates)
    # * a `:numeric` input (where the user could choose from a set of pre-defined numbers)
    # * a `:time_zone` input (where you want to provide your own set of choices instead of relying on Rails)
    # * a `:country` input (no need for a plugin really)
    #
    # Within the standard `<li>` wrapper, the output is a `<label>` tag followed by a `<select>` 
    # tag containing `<option>` tags.
    #
    # For inputs that map to associations on the object model, Formtastic will automatically load
    # in a collection of objects on the association as options to choose from. This might be an 
    # `Author.all` on a `Post` form with an input for a `belongs_to :user` association, or a 
    # `Tag.all` for a `Post` form with an input for a `has_and_belongs_to_many :tags` association. 
    # You can override or customise this collection and the `<option>` tags it will render through
    # the `:collection` option (see examples).
    #
    # The way on which Formtastic renders the `value` attribute and content of each `<option>` tag
    # is customisable through the `:label_method` and `:value_method` options. When not provided,
    # we fall back to a list of methods to try on each object such as `:to_label`, `:name` and 
    # `:to_s`, which are defined in the configurations `collection_label_methods` and 
    # `collection_value_methods` (see examples below).
    #
    # @example Basic `belongs_to` example with full form context
    #
    #     <%= semantic_form_for @post do |f| %>
    #       <%= f.inputs do %>
    #         <%= f.input :author, :as => :select %>
    #       <% end %>
    #     <% end %>
    #     
    #     <form...>
    #       <fieldset>
    #         <ol>
    #           <li class='select'>
    #             <label for="post_author_id">Author</label>
    #             <select id="post_author_id" name="post[post_author_id]">
    #               <option value=""></option>
    #               <option value="1">Justin</option>
    #               <option value="3">Kate</option>
    #               <option value="2">Amelia</option>
    #             </select>
    #           </li>
    #         </ol>
    #       </fieldset>
    #     </form>
    #
    # @example Basic `has_many` or `has_and_belongs_to_many` example with full form context
    #
    #     <%= semantic_form_for @post do |f| %>
    #       <%= f.inputs do %>
    #         <%= f.input :tags, :as => :select %>
    #       <% end %>
    #     <% end %>
    #     
    #     <form...>
    #       <fieldset>
    #         <ol>
    #           <li class='select'>
    #             <label for="post_tag_ids">Author</label>
    #             <select id="post_tag_ids" name="post[tag_ids]" multiple="true">
    #               <option value="1">Ruby</option>
    #               <option value="6">Rails</option>
    #               <option value="3">Forms</option>
    #               <option value="4">Awesome</option>
    #             </select>
    #           </li>
    #         </ol>
    #       </fieldset>
    #     </form>
    #
    # @example Override Formtastic's assumption on when you need a multi select
    #   <%= f.input :authors, :as => :select, :input_html => { :multiple => true } %>
    #   <%= f.input :authors, :as => :select, :input_html => { :multiple => false } %>
    #
    # @example The `:collection` option can be used to customize the choices
    #   <%= f.input :author, :as => :select, :collection => @authors %>
    #   <%= f.input :author, :as => :select, :collection => Author.all %>
    #   <%= f.input :author, :as => :select, :collection => Author.some_named_scope %>
    #   <%= f.input :author, :as => :select, :collection => [Author.find_by_login("justin"), Category.find_by_name("kate")] %>
    #   <%= f.input :author, :as => :select, :collection => ["Justin", "Kate"] %>
    #   <%= f.input :author, :as => :select, :collection => [["Justin", "justin"], ["Kate", "kate"]] %>
    #   <%= f.input :author, :as => :select, :collection => [["Justin", "1"], ["Kate", "3"]] %>
    #   <%= f.input :author, :as => :select, :collection => [["Justin", 1], ["Kate", 3]] %>
    #   <%= f.input :author, :as => :select, :collection => 1..5 %>
    #   <%= f.input :author, :as => :select, :collection => "<option>your own options HTML string</option>" %>
    #   <%= f.input :author, :as => :select, :collection => options_for_select(...) %>
    #   <%= f.input :author, :as => :select, :collection => options_from_collection_for_select(...) %>
    #   <%= f.input :author, :as => :select, :collection => grouped_options_for_select(...) %>
    #   <%= f.input :author, :as => :select, :collection => time_zone_options_for_select(...) %>
    # 
    # @example The `:label_method` can be used to call a different method (or a Proc) on each object in the collection for rendering the label text (it'll try the methods like `to_s` in `collection_label_methods` config by default)
    #   <%= f.input :author, :as => :select, :label_method => :name %>
    #   <%= f.input :author, :as => :select, :label_method => :name_with_post_count
    #   <%= f.input :author, :as => :select, :label_method => Proc.new { |a| "#{c.name} (#{pluralize("post", a.posts.count)})" }
    # 
    # @example The `:value_method` can be used to call a different method (or a Proc) on each object in the collection for rendering the value for each checkbox (it'll try the methods like `id` in `collection_value_methods` config by default)
    #   <%= f.input :author, :as => :select, :value_method => :login %>
    #   <%= f.input :author, :as => :select, :value_method => Proc.new { |c| c.full_name.downcase.underscore }
    # 
    # @example Set HTML attributes on the `<select>` tag with `:input_html`
    #   <%= f.input :authors, :as => :select, :input_html => { :size => 20, :multiple => true, :class => "special" } %>
    # 
    # @example Set HTML attributes on the `<li>` wrapper with `:wrapper_html`
    #   <%= f.input :authors, :as => :select, :wrapper_html => { :class => "special" } %>
    #
    # @example Exclude or include the blank option at the top of the select, or change the prompt
    #   <%= f.input :author, :as => :select, :input_html => { :include_blank => false } %>
    #   <%= f.input :author, :as => :select, :input_html => { :include_blank => true } %>
    #   <%= f.input :author, :as => :select, :input_html => { :prompt => "Please select an Author..." } %>
    #
    # @example Group options an `<optgroup>` with the `:group_by` and `:group_label_method` options (`belongs_to` associations only)
    #   <%= f.input :author, :as => :select, :group_by => :continent %>
    #
    # @see Formtastic::Helpers::InputsHelper#input InputsHelper#input for full documetation of all possible options.
    # @see Formtastic::Inputs::CheckBoxesInput CheckBoxesInput as an alternative for `has_many` and `has_and_belongs_to_many` associations
    # @see Formtastic::Inputs::RadioInput RadioInput as an alternative for `belongs_to` associations
    module SelectInput
      include Formtastic::Inputs::Base
      include Formtastic::Reflection
      
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
      def create_boolean_collection(options) #:nodoc:
        options[:true] ||= Formtastic::I18n.t(:yes)
        options[:false] ||= Formtastic::I18n.t(:no)
        options[:value_as_class] = true unless options.key?(:value_as_class)
  
        [ [ options.delete(:true), true], [ options.delete(:false), false ] ]
      end
      
      # Return the label collection method when none is supplied using the
      # values set in collection_label_methods.
      def detect_label_method(collection) #:nodoc:
        detect_label_and_value_method!(collection).first
      end
      
      # Detects the method to call for fetching group members from the groups when grouping select options
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