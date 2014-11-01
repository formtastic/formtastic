# encoding: utf-8
require 'spec_helper'

describe 'Formtastic::FormBuilder#action' do
  include_context 'Action Helper' # from spec/support/shared_examples.rb

  # TODO: remove this in Formtastic 4.0
  describe 'instantiating an action class' do
    context 'of unknown action' do
      it "should try to load class named as the action" do
        expect {
          semantic_form_for(@new_post) do |builder|
            builder.action(:destroy)
          end
        }.to raise_error(Formtastic::UnknownActionError, 'Unable to find action destroy')
      end
    end
  end
end
