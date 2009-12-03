module CustomMacros
  
  def self.included(base)
    base.extend(ClassMethods)    
  end
  
  module ClassMethods
    
    def it_should_have_input_wrapper_with_class(class_name)
      it "should have input wrapper with class '#{class_name}'" do
        output_buffer.should have_tag("form li.#{class_name}") 
      end
    end
    
    def it_should_have_input_wrapper_with_id(id_string)
      it "should have input wrapper with id '#{id_string}'" do
        output_buffer.should have_tag("form li##{id_string}") 
      end
    end
    
    def it_should_not_have_a_label
      it "should not have a label" do
        output_buffer.should_not have_tag("form li label") 
      end
    end
    
    def it_should_have_a_nested_fieldset
      it "should have a nested_fieldset" do
        output_buffer.should have_tag("form li fieldset") 
      end
    end
    
    def it_should_have_label_with_text(string_or_regex)
      it "should have a label with text '#{string_or_regex}'" do
        output_buffer.should have_tag("form li label", string_or_regex) 
      end
    end
    
    def it_should_have_label_for(element_id)
      it "should have a label for ##{element_id}" do
        output_buffer.should have_tag("form li label[@for='#{element_id}']")
      end
    end
    
    def it_should_have_input_with_id(element_id)
      it "should have an input with id '#{element_id}'" do
        output_buffer.should have_tag("form li input##{element_id}")
      end
    end
    
    def it_should_have_input_with_type(input_type)
      it "should have a #{input_type} input" do
        output_buffer.should have_tag("form li input[@type=\"#{input_type}\"]")
      end
    end
    
    def it_should_have_input_with_name(name)
      it "should have an input named #{name}" do
        output_buffer.should have_tag("form li input[@name=\"#{name}\"]")
      end
    end
    
    def it_should_have_textarea_with_name(name)
      it "should have an input named #{name}" do
        output_buffer.should have_tag("form li textarea[@name=\"#{name}\"]")
      end
    end
    
    def it_should_have_textarea_with_id(element_id)
      it "should have an input with id '#{element_id}'" do
        output_buffer.should have_tag("form li textarea##{element_id}")
      end
    end
    
    def it_should_use_default_text_field_size_when_method_has_no_database_column(as)
      it 'should use default_text_field_size when method has no database column' do
        @new_post.stub!(:column_for_attribute).and_return(nil) # Return a nil column
        
        semantic_form_for(@new_post) do |builder|
          concat(builder.input(:title, :as => as))
        end
        output_buffer.should have_tag("form li input[@size='#{Formtastic::SemanticFormBuilder.default_text_field_size}']")
      end
    end
    
    def it_should_apply_custom_input_attributes_when_input_html_provided(as)
      it 'it should apply custom input attributes when input_html provided' do
        semantic_form_for(@new_post) do |builder|
          concat(builder.input(:title, :as => as, :input_html => { :class => 'myclass' }))
        end
        output_buffer.should have_tag("form li input.myclass")
      end
    end
    
    def it_should_apply_custom_for_to_label_when_input_html_id_provided(as)
      it 'it should apply custom for to label when input_html :id provided' do
        semantic_form_for(@new_post) do |builder|
          concat(builder.input(:title, :as => as, :input_html => { :id => 'myid' }))
        end
        output_buffer.should have_tag('form li label[@for="myid"]')
      end
    end
    
    def it_should_have_maxlength_matching_column_limit
      it 'should have a maxlength matching column limit' do
        @new_post.column_for_attribute(:title).limit.should == 50
        output_buffer.should have_tag("form li input[@maxlength='50']")
      end
    end
    
    def it_should_use_default_text_field_size_for_columns_longer_than_default_text_field_size(as)
      it 'should use default_text_field_size for columns longer than default_text_field_size' do
        default_size = Formtastic::SemanticFormBuilder.default_text_field_size
        @new_post.stub!(:column_for_attribute).and_return(mock('column', :type => as, :limit => default_size * 2))

        semantic_form_for(@new_post) do |builder|
          concat(builder.input(:title, :as => as))
        end

        output_buffer.should have_tag("form li input[@size='#{default_size}']")
      end
    end
    
    def it_should_use_column_size_for_columns_shorter_than_default_text_field_size(as)
      it 'should use the column size for columns shorter than default_text_field_size' do
        column_limit_shorted_than_default = 1
        @new_post.stub!(:column_for_attribute).and_return(mock('column', :type => as, :limit => column_limit_shorted_than_default))

        semantic_form_for(@new_post) do |builder|
          concat(builder.input(:title, :as => as))
        end

        output_buffer.should have_tag("form li input[@size='#{column_limit_shorted_than_default}']")
      end
    end
    
    def it_should_apply_error_logic_for_input_type(type)
      describe 'when there are errors on the object for this method' do
        before do
          @title_errors = ['must not be blank', 'must be longer than 10 characters', 'must be awesome']
          @errors = mock('errors')
          @errors.stub!(:[]).with(:title).and_return(@title_errors)
          @new_post.stub!(:errors).and_return(@errors)
        end

        it 'should apply an errors class to the list item' do
          semantic_form_for(@new_post) do |builder|
            concat(builder.input(:title, :as => type))
          end
          output_buffer.should have_tag('form li.error')
        end

        it 'should not wrap the input with the Rails default error wrapping' do
          semantic_form_for(@new_post) do |builder|
            concat(builder.input(:title, :as => type))
          end
          output_buffer.should_not have_tag('div.fieldWithErrors')
        end

        it 'should render a paragraph for the errors' do
          ::Formtastic::SemanticFormBuilder.inline_errors = :sentence
          semantic_form_for(@new_post) do |builder|
            concat(builder.input(:title, :as => type))
          end
          output_buffer.should have_tag('form li.error p.inline-errors')
        end

        it 'should not display an error list' do
          ::Formtastic::SemanticFormBuilder.inline_errors = :list
          semantic_form_for(@new_post) do |builder|
            concat(builder.input(:title, :as => type))
          end
          output_buffer.should have_tag('form li.error ul.errors')
        end
      end

      describe 'when there are no errors on the object for this method' do
        before do
          semantic_form_for(@new_post) do |builder|
            concat(builder.input(:title, :as => type))
          end
        end

        it 'should not apply an errors class to the list item' do
          output_buffer.should_not have_tag('form li.error')
        end

        it 'should not render a paragraph for the errors' do
          output_buffer.should_not have_tag('form li.error p.inline-errors')
        end

        it 'should not display an error list' do
          output_buffer.should_not have_tag('form li.error ul.errors')
        end
      end

      describe 'when no object is provided' do
        before do
          semantic_form_for(:project, :url => 'http://test.host') do |builder|
            concat(builder.input(:title, :as => type))
          end
        end

        it 'should not apply an errors class to the list item' do
          output_buffer.should_not have_tag('form li.error')
        end

        it 'should not render a paragraph for the errors' do
          output_buffer.should_not have_tag('form li.error p.inline-errors')
        end

        it 'should not display an error list' do
          output_buffer.should_not have_tag('form li.error ul.errors')
        end
      end
    end
    
    def it_should_call_find_on_association_class_when_no_collection_is_provided(as)
      it "should call find on the association class when no collection is provided" do
        ::Author.should_receive(:find)
        semantic_form_for(@new_post) do |builder|
          concat(builder.input(:author, :as => as))
        end
      end
    end

    def it_should_select_existing_datetime_else_current(*datetime_parts)
      describe "default value" do
        before do
          @new_post.should_receive(:publish_at=).any_number_of_times
        end

        describe "when attribute value is present" do
          before do
            @output_buffer = ''
            publish_at_value = 1.year.ago + 2.month + 3.day + 4.hours + 5.minutes # No comment =)
            @new_post.stub!(:publish_at).and_return(publish_at_value)

            semantic_form_for(@new_post) do |builder|
              concat(builder.input(:publish_at, :as => :datetime))
            end
          end

          it "should select the present value by default" do
            # puts output_buffer
            output_buffer.should have_tag("form li select#post_publish_at_1i option[@selected='selected'][@value='#{@new_post.publish_at.year}']") if datetime_parts.include?(:year)
            output_buffer.should have_tag("form li select#post_publish_at_2i option[@selected='selected'][@value='#{@new_post.publish_at.month}']") if datetime_parts.include?(:month)
            output_buffer.should have_tag("form li select#post_publish_at_3i option[@selected='selected'][@value='#{@new_post.publish_at.day}']") if datetime_parts.include?(:day)
            output_buffer.should have_tag("form li select#post_publish_at_4i option[@selected='selected'][@value='#{@new_post.publish_at.strftime("%H")}']") if datetime_parts.include?(:hour)
            output_buffer.should have_tag("form li select#post_publish_at_5i option[@selected='selected'][@value='#{@new_post.publish_at.strftime("%M")}']") if datetime_parts.include?(:minute)
            #output_buffer.should have_tag("form li select#post_publish_at_6i option[@selected='selected'][@value='#{@new_post.publish_at.sec}']") if datetime_parts.include?(:second)
          end
        end

        describe "when no attribute value is present" do
          before do
            @output_buffer = ''
            @new_post.stub!(:publish_at).and_return(nil)
            @current_time = ::Time.now

            semantic_form_for(@new_post) do |builder|
              concat(builder.input(:publish_at, :as => :datetime))
            end
          end

          it "should select the current day/time by default" do
            # puts output_buffer
            output_buffer.should have_tag("form li select#post_publish_at_1i option[@selected='selected'][@value='#{@current_time.year}']") if datetime_parts.include?(:year)
            output_buffer.should have_tag("form li select#post_publish_at_2i option[@selected='selected'][@value='#{@current_time.month}']") if datetime_parts.include?(:month)
            output_buffer.should have_tag("form li select#post_publish_at_3i option[@selected='selected'][@value='#{@current_time.day}']") if datetime_parts.include?(:day)
            output_buffer.should have_tag("form li select#post_publish_at_4i option[@selected='selected'][@value='#{@current_time.strftime("%H")}']") if datetime_parts.include?(:hour)
            output_buffer.should have_tag("form li select#post_publish_at_5i option[@selected='selected'][@value='#{@current_time.strftime("%M")}']") if datetime_parts.include?(:minute)
            #output_buffer.should have_tag("form li select#post_publish_at_6i option[@selected='selected'][@value='#{@custom_default_time.sec}']") if datetime_parts.include?(:second)
          end

          # TODO: Scenario when current time is not a possible choice (because of specified date/time ranges)?
        end
      end
    end

    def it_should_select_explicit_default_value_if_set(*datetime_parts)
      describe 'when :selected is set' do
        before do
          @output_buffer = ''
        end

        # Note: Not possible to override default selected value for time_zone input
        # without overriding Rails core helper. This Rails helper works "a bit different". =/
        #
        describe "no selected items" do
          before do
            @default_time = 2.days.ago
            @new_post.stub!(:publish_at).and_return(@default_time)

            semantic_form_for(@new_post) do |builder|
              concat(builder.input(:publish_at, :as => :time_zone, :selected => nil))
            end
          end

          it 'should not have any selected item(s)' do
            output_buffer.should_not have_tag("form li select#post_publish_at_1i option[@selected='selected']")
          end
        end

        describe "single selected item" do
          before do
            @custom_default_time = 5.days.ago
            @new_post.stub!(:publish_at).and_return(2.days.ago)

            semantic_form_for(@new_post) do |builder|
              concat(builder.input(:publish_at, :as => :datetime, :selected => @custom_default_time))
            end
          end

          it "should select the specified value" do
            output_buffer.should have_tag("form li select#post_publish_at_1i option[@selected='selected'][@value='#{@custom_default_time.year}']") if datetime_parts.include?(:year)
            output_buffer.should have_tag("form li select#post_publish_at_2i option[@selected='selected'][@value='#{@custom_default_time.month}']") if datetime_parts.include?(:month)
            output_buffer.should have_tag("form li select#post_publish_at_3i option[@selected='selected'][@value='#{@custom_default_time.day}']") if datetime_parts.include?(:day)
            output_buffer.should have_tag("form li select#post_publish_at_4i option[@selected='selected'][@value='#{@custom_default_time.strftime("%H")}']") if datetime_parts.include?(:hour)
            output_buffer.should have_tag("form li select#post_publish_at_5i option[@selected='selected'][@value='#{@custom_default_time.strftime("%M")}']") if datetime_parts.include?(:minute)
            #output_buffer.should have_tag("form li select#post_publish_at_6i option[@selected='selected'][@value='#{@custom_default_time.sec}']") if datetime_parts.include?(:second)
          end
        end

      end
    end

    def it_should_use_the_collection_when_provided(as, countable)
      describe 'when the :collection option is provided' do

        before do
          @authors = ::Author.find(:all) * 2
          output_buffer.replace '' # clears the output_buffer from the before block, hax!
        end

        it 'should not call find() on the parent class' do
          ::Author.should_not_receive(:find)
          semantic_form_for(@new_post) do |builder|
            concat(builder.input(:author, :as => as, :collection => @authors))
          end
        end

        it 'should use the provided collection' do
          semantic_form_for(@new_post) do |builder|
            concat(builder.input(:author, :as => as, :collection => @authors))
          end
          output_buffer.should have_tag("form li.#{as} #{countable}", :count => @authors.size + (as == :select ? 1 : 0))
        end

        describe 'and the :collection is an array of strings' do
          before do
            @categories = [ 'General', 'Design', 'Development', 'Quasi-Serious Inventions' ]
          end

          it "should use the string as the label text and value for each #{countable}" do
            semantic_form_for(@new_post) do |builder|
              concat(builder.input(:category_name, :as => as, :collection => @categories))
            end

            @categories.each do |value|
              output_buffer.should have_tag("form li.#{as}", /#{value}/)
              output_buffer.should have_tag("form li.#{as} #{countable}[@value='#{value}']")
            end
          end

          if as == :radio
            it 'should generate a sanitized label for attribute' do
              @bob.stub!(:category_name).and_return(@categories)
              semantic_form_for(@new_post) do |builder|
                builder.semantic_fields_for(@bob) do |bob_builder|
                  concat(bob_builder.input(:category_name, :as => as, :collection => @categories))
                end
              end
              output_buffer.should have_tag("form li fieldset ol li label[@for='post_author_category_name_general']")
              output_buffer.should have_tag("form li fieldset ol li label[@for='post_author_category_name_design']")
              output_buffer.should have_tag("form li fieldset ol li label[@for='post_author_category_name_development']")
              output_buffer.should have_tag("form li fieldset ol li label[@for='post_author_category_name_quasiserious_inventions']")
            end
          end
        end

        describe 'and the :collection is a hash of strings' do
          before do
            @categories = { 'General' => 'gen', 'Design' => 'des','Development' => 'dev' }
          end

          it "should use the key as the label text and the hash value as the value attribute for each #{countable}" do
            semantic_form_for(@new_post) do |builder|
              concat(builder.input(:category_name, :as => as, :collection => @categories))
            end

            @categories.each do |label, value|
              output_buffer.should have_tag("form li.#{as}", /#{label}/)
              output_buffer.should have_tag("form li.#{as} #{countable}[@value='#{value}']")
            end
          end
        end

        describe 'and the :collection is an array of arrays' do
          before do
            @categories = { 'General' => 'gen', 'Design' => 'des', 'Development' => 'dev' }.to_a
          end

          it "should use the first value as the label text and the last value as the value attribute for #{countable}" do
            semantic_form_for(@new_post) do |builder|
              concat(builder.input(:category_name, :as => as, :collection => @categories))
            end

            @categories.each do |text, value|
              label = as == :select ? :option : :label
              output_buffer.should have_tag("form li.#{as} #{label}", /#{text}/i)
              output_buffer.should have_tag("form li.#{as} #{countable}[@value='#{value.to_s}']")
              output_buffer.should have_tag("form li.#{as} #{countable}#post_category_name_#{value.to_s}") if as == :radio
            end
          end
        end
        
        if as == :radio
          describe 'and the :collection is an array of arrays with boolean values' do
            before do
              @choices = { 'Yeah' => true, 'Nah' => false }.to_a
            end
        
            it "should use the first value as the label text and the last value as the value attribute for #{countable}" do
              semantic_form_for(@new_post) do |builder|
                concat(builder.input(:category_name, :as => as, :collection => @choices))
              end
              
              output_buffer.should have_tag("form li.#{as} #{countable}#post_category_name_true")
              output_buffer.should have_tag("form li.#{as} #{countable}#post_category_name_false")
            end
          end
        end
        
        describe 'and the :collection is an array of symbols' do
          before do
            @categories = [ :General, :Design, :Development ]
          end

          it "should use the symbol as the label text and value for each #{countable}" do
            semantic_form_for(@new_post) do |builder|
              concat(builder.input(:category_name, :as => as, :collection => @categories))
            end

            @categories.each do |value|
              label = as == :select ? :option : :label
              output_buffer.should have_tag("form li.#{as} #{label}", /#{value}/i)
              output_buffer.should have_tag("form li.#{as} #{countable}[@value='#{value.to_s}']")
            end
          end
        end
        
        describe 'and the :collection is an OrderedHash of strings' do
          before do
            @categories = ActiveSupport::OrderedHash.new('General' => 'gen', 'Design' => 'des','Development' => 'dev')
          end

          it "should use the key as the label text and the hash value as the value attribute for each #{countable}" do
            semantic_form_for(@new_post) do |builder|
              concat(builder.input(:category_name, :as => as, :collection => @categories))
            end

            @categories.each do |label, value|
              output_buffer.should have_tag("form li.#{as}", /#{label}/)
              output_buffer.should have_tag("form li.#{as} #{countable}[@value='#{value}']")
            end
          end
          
        end
        
        describe 'when the :label_method option is provided' do
          
          describe 'as a symbol' do
            before do
              semantic_form_for(@new_post) do |builder|
                concat(builder.input(:author, :as => as, :label_method => :login))
              end
            end

            it 'should have options with text content from the specified method' do
              ::Author.find(:all).each do |author|
                output_buffer.should have_tag("form li.#{as}", /#{author.login}/)
              end
            end
          end
          
          describe 'as a proc' do
            before do
              semantic_form_for(@new_post) do |builder|
                concat(builder.input(:author, :as => as, :label_method => Proc.new {|a| a.login.reverse }))
              end
            end
            
            it 'should have options with the proc applied to each' do
              ::Author.find(:all).each do |author|
                output_buffer.should have_tag("form li.#{as}", /#{author.login.reverse}/)
              end
            end
          end
          
        end

        describe 'when the :label_method option is not provided' do
          ::Formtastic::SemanticFormBuilder.collection_label_methods.each do |label_method|

            describe "when the collection objects respond to #{label_method}" do
              before do
                @fred.stub!(:respond_to?).and_return { |m| m.to_s == label_method }
                ::Author.find(:all).each { |a| a.stub!(label_method).and_return('The Label Text') }

                semantic_form_for(@new_post) do |builder|
                  concat(builder.input(:author, :as => as))
                end
              end

              it "should render the options with #{label_method} as the label" do
                ::Author.find(:all).each do |author|
                  output_buffer.should have_tag("form li.#{as}", /The Label Text/)
                end
              end
            end

          end
        end

        describe 'when the :value_method option is provided' do
          
          describe 'as a symbol' do
            before do
              semantic_form_for(@new_post) do |builder|
                concat(builder.input(:author, :as => as, :value_method => :login))
              end
            end
            
            it 'should have options with values from specified method' do
              ::Author.find(:all).each do |author|
                output_buffer.should have_tag("form li.#{as} #{countable}[@value='#{author.login}']")
              end
            end
          end
          
          describe 'as a proc' do
            before do
              semantic_form_for(@new_post) do |builder|
                concat(builder.input(:author, :as => as, :value_method => Proc.new {|a| a.login.reverse }))
              end
            end

            it 'should have options with the proc applied to each value' do
              ::Author.find(:all).each do |author|
                output_buffer.should have_tag("form li.#{as} #{countable}[@value='#{author.login.reverse}']")
              end
            end
          end
        end

      end
    end

  end
end