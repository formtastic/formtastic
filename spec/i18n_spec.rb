# encoding: utf-8
require 'spec_helper'

RSpec.describe 'Formtastic::I18n' do

  FORMTASTIC_KEYS = [:required, :yes, :no, :create, :update].freeze

  it "should be defined" do
    expect { Formtastic::I18n }.not_to raise_error
  end

  describe "default translations" do
    it "should be defined" do
      expect { Formtastic::I18n::DEFAULT_VALUES }.not_to raise_error
      expect(Formtastic::I18n::DEFAULT_VALUES.is_a?(::Hash)).to eq(true)
    end

    it "should exists for the core I18n lookup keys" do
      expect((Formtastic::I18n::DEFAULT_VALUES.keys & FORMTASTIC_KEYS).size).to eq(FORMTASTIC_KEYS.size)
    end
  end

  describe "when I18n locales are available" do

    before do
      @formtastic_strings = {
          :yes            => 'Default Yes',
          :no             => 'Default No',
          :create         => 'Default Create %{model}',
          :update         => 'Default Update %{model}',
          :custom_scope   => {
              :duck           => 'Duck',
              :duck_pond      => '%{ducks} ducks in a pond'
            }
        }
      ::I18n.backend.store_translations :en, :formtastic => @formtastic_strings
    end

    after do
      ::I18n.backend.reload!
    end

    it "should translate core strings correctly" do
      ::I18n.backend.store_translations :en, {:formtastic => {:required => 'Default Required'}}
      expect(Formtastic::I18n.t(:required)).to  eq("Default Required")
      expect(Formtastic::I18n.t(:yes)).to       eq("Default Yes")
      expect(Formtastic::I18n.t(:no)).to        eq("Default No")
      expect(Formtastic::I18n.t(:create, :model => 'Post')).to eq("Default Create Post")
      expect(Formtastic::I18n.t(:update, :model => 'Post')).to eq("Default Update Post")
    end

    it "should all belong to scope 'formtastic'" do
      expect(Formtastic::I18n.t(:duck, :scope => [:custom_scope])).to eq('Duck')
    end

    it "should override default I18n lookup args if these are specified" do
      expect(Formtastic::I18n.t(:duck_pond, :scope => [:custom_scope], :ducks => 15)).to eq('15 ducks in a pond')
    end

    it "should be possible to override default values" do
      expect(Formtastic::I18n.t(:required, :default => 'Nothing found!')).to eq('Nothing found!')
    end

  end

  describe "when no I18n locales are available" do

    before do
      ::I18n.backend.reload!
    end

    it "should use default strings" do
      (Formtastic::I18n::DEFAULT_VALUES.keys).each do |key|
        expect(Formtastic::I18n.t(key, :model => '%{model}')).to eq(Formtastic::I18n::DEFAULT_VALUES[key])
      end
    end

  end

  describe "I18n string lookups" do

    include FormtasticSpecHelper

    before do
      @output_buffer = ''
      mock_everything

      ::I18n.backend.store_translations :en, {:formtastic => {
          :labels => {
              :author   => { :name => "Top author name transation" },
              :post     => {:title => "Hello post!", :author => {:name => "Hello author name!"}},
              :project  => {:title => "Hello project!"},
            }
        }, :helpers => {
          :label => {
            :post => {:body => "Elaborate..." },
            :author => { :login => "Hello login" }
          }
        }}

      allow(@new_post).to receive(:title)
      allow(@new_post).to receive(:column_for_attribute).with(:title).and_return(double('column', :type => :string, :limit => 255))
    end

    after do
      ::I18n.backend.reload!
    end

    it "lookup scopes should be defined" do
      with_config :i18n_lookups_by_default, true do
        expect { Formtastic::I18n::SCOPES }.not_to raise_error
      end
    end

    it "should be able to translate with namespaced object" do
      with_config :i18n_lookups_by_default, true do
        concat(semantic_form_for(@new_post) do |builder|
          concat(builder.input(:title))
        end)
        expect(output_buffer).to have_tag("form label", :text => /Hello post!/)
      end
    end

    it "should be able to translate without form-object" do
      with_config :i18n_lookups_by_default, true do
        concat(semantic_form_for(:project, :url => 'http://test.host') do |builder|
          concat(builder.input(:title))
        end)
        expect(output_buffer).to have_tag("form label", :text => /Hello project!/)
      end
    end

    it "should be able to translate when method name is same as model" do
      with_config :i18n_lookups_by_default, true do
        concat(semantic_form_for(:project, :url => 'http://test.host') do |builder|
          concat(builder.input(:author))
        end)
        expect(output_buffer).to have_tag("form label", :text => /Author/)
      end
    end

    it 'should be able to translate nested objects with nested translations' do
      with_config :i18n_lookups_by_default, true do
        concat(semantic_form_for(@new_post) do |builder|
          concat(builder.semantic_fields_for(:author) do |f|
            concat(f.input(:name))
          end)
        end)
        expect(output_buffer).to have_tag("form label", :text => /Hello author name!/)
      end
    end

    it 'should be able to translate nested objects with top level translations' do
      with_config :i18n_lookups_by_default, true do
        concat(semantic_form_for(@new_post) do |builder|
          builder.semantic_fields_for(:author) do |f|
            concat(f.input(:name))
          end
        end)
        expect(output_buffer).to have_tag("form label", :text => /Hello author name!/)
      end
    end

    it 'should be able to translate nested objects with nested object translations' do
      with_config :i18n_lookups_by_default, true do
        concat(semantic_form_for(@new_post) do |builder|
          builder.semantic_fields_for(:project) do |f|
            concat(f.input(:title))
          end
        end)
        expect(output_buffer).to have_tag("form label", :text => /Hello project!/)
      end
    end
    
    it 'should be able to translate nested forms with top level translations' do
      with_config :i18n_lookups_by_default, true do
        concat(semantic_form_for(:post) do |builder|
          builder.semantic_fields_for(:author) do |f|
            concat(f.input(:name))
          end
        end)
        expect(output_buffer).to have_tag("form label", :text => /Hello author name!/)
      end
    end

    it 'should be able to translate helper label as Rails does' do
      with_config :i18n_lookups_by_default, true do
        concat(semantic_form_for(@new_post) do |builder|
          concat(builder.input(:body))
        end)
        expect(output_buffer).to have_tag("form label", :text => /Elaborate/)
      end
    end
    
    it 'should be able to translate nested helper label as Rails does' do
      with_config :i18n_lookups_by_default, true do
        concat(semantic_form_for(@new_post) do |builder|
          concat(builder.inputs(:for => :author) do |f|
            concat(f.input(:login))
          end)
        end)
        expect(output_buffer).to have_tag("form label", :text => /Hello login/)
      end
    end

    # TODO: Add spec for namespaced models?

  end

end
