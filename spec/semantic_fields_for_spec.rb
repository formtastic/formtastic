# encoding: utf-8
require 'spec_helper'

describe 'SemanticFormBuilder#semantic_fields_for' do

  include FormtasticSpecHelper

  before do
    @output_buffer = ''
    mock_everything
    @new_post.stub!(:author).and_return(::Author.new)
  end

  it 'yields an instance of SemanticFormHelper.builder' do
    semantic_form_for(@new_post) do |builder|
      builder.semantic_fields_for(:author) do |nested_builder|
        nested_builder.class.should == ::Formtastic::SemanticFormHelper.builder
      end
    end
  end

  it 'nests the object name' do
    semantic_form_for(@new_post) do |builder|
      builder.semantic_fields_for(@bob) do |nested_builder|
        nested_builder.object_name.should == 'post[author]'
      end
    end
  end

  it 'should sanitize html id for li tag' do
    @bob.stub!(:column_for_attribute).and_return(mock('column', :type => :string, :limit => 255))
    form = semantic_form_for(@new_post) do |builder|
      concat(builder.semantic_fields_for(@bob, :index => 1) do |nested_builder|
        concat(nested_builder.inputs(:login))
      end)
    end
    output_buffer.concat(form) if Formtastic::Util.rails3?
    output_buffer.should have_tag('form fieldset.inputs #post_author_1_login_input')
    # Not valid selector, so using good ol' regex
    output_buffer.should_not =~ /id="post\[author\]_1_login_input"/
    # <=> output_buffer.should_not have_tag('form fieldset.inputs #post[author]_1_login_input')
  end

  it 'should use namespace provided in nested fields' do
    @bob.stub!(:column_for_attribute).and_return(mock('column', :type => :string, :limit => 255))
    form = semantic_form_for(@new_post, :namespace => 'context2') do |builder|
      concat(builder.semantic_fields_for(@bob, :index => 1) do |nested_builder|
        concat(nested_builder.inputs(:login))
      end)
    end
    output_buffer.concat(form) if Formtastic::Util.rails3?
    output_buffer.should have_tag('form fieldset.inputs #context2_post_author_1_login_input')
  end
  
  context "when I rendered my own hidden id input" do 
    
    before do
      output_buffer.replace ''
      
      @fred.posts.size.should == 1
      @fred.posts.first.stub!(:persisted?).and_return(true)
      @fred.stub!(:posts_attributes=)

      form = semantic_form_for(@fred) do |builder|
        concat(builder.semantic_fields_for(:posts) do |nested_builder|
          concat(nested_builder.input(:id, :as => :hidden))
          concat(nested_builder.input(:title))
        end)
      end
      output_buffer.concat(form) if Formtastic::Util.rails3?
    end
  
    it "should only render one hidden input (my one)" do
      output_buffer.should have_tag 'input#author_posts_attributes_0_id', :count => 1
    end
    
    it "should render the hidden input inside an li.hidden" do
      output_buffer.should have_tag 'li.hidden input#author_posts_attributes_0_id'
    end
  end

end

