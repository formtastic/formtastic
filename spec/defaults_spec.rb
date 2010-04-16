# coding: utf-8
require File.join(File.dirname(__FILE__), *%w[spec_helper])

describe 'Formtastic::SemanticFormBuilder-defaults' do
  
  # Note: This spec might make better sense somewhere else. Just temporary.
  
  describe "required string" do
    
    it "should render proc with I18n correctly" do
      ::I18n.backend.store_translations :en, :formtastic => {:required => 'Haha!'}
      
      required_string = Formtastic::SemanticFormBuilder.required_string
      required_string = required_string.is_a?(::Proc) ? required_string.call : required_string.to_s
      required_string.should == %{<abbr title="Haha!">*</abbr>}
    end
    
  end
  
end