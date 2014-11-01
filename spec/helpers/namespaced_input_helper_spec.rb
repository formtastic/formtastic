# encoding: utf-8
require 'spec_helper'

describe 'with input class finder' do
  include_context 'form builder'

  before {
    allow(Formtastic::FormBuilder)
    .to receive(:input_class_finder).and_return(Formtastic::InputClassFinder)
  }
  it_behaves_like 'Input Helper' # from spec/support/shared_examples.rb


  describe 'instantiating an input class' do
    describe 'when instantiated multiple times with the same input type' do

      it "should be cached (not calling the internal methods)" do
        # TODO this is really tied to the underlying implementation
        concat(semantic_form_for(@new_post) do |builder|
          Formtastic::InputClassFinder.should_receive(:new).once.and_call_original
          builder.input(:title, :as => :string)
          builder.input(:title, :as => :string)
        end)
      end
    end

    it "should delegate to InputClassFinder" do
      concat(semantic_form_for(@new_post) do |builder|
        Formtastic::InputClassFinder.any_instance.should_receive(:find).
            with(:string).and_call_original

        builder.input(:title, :as => :string)
      end)
    end
  end
end
