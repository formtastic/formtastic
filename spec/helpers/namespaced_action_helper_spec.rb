require 'spec_helper'

describe 'with action class finder' do
  include_context 'form builder'

  before {
    allow(Formtastic::FormBuilder)
      .to receive(:action_class_finder).and_return(Formtastic::ActionClassFinder)
  }

  it_behaves_like 'Action Helper'

  describe 'instantiating an action class' do
    it "should delegate to ActionClassFinder" do
      concat(semantic_form_for(@new_post) do |builder|
        Formtastic::ActionClassFinder.any_instance.should_receive(:find).
            with(:button).and_call_original

        builder.action(:submit, :as => :button)
      end)
    end

    describe 'when instantiated multiple times with the same action type' do
      it "should be cached" do
        concat(semantic_form_for(@new_post) do |builder|
          Formtastic::ActionClassFinder.should_receive(:new).once.and_call_original
          builder.action(:submit, :as => :button)
          builder.action(:submit, :as => :button)
        end)
      end
    end

    context 'of unknown action' do
      it "should try to load class named as the action" do
        expect {
          semantic_form_for(@new_post) do |builder|
            builder.action(:destroy)
          end
        }.to raise_error(Formtastic::UnknownActionError, 'Unable to find action class DestroyAction')
      end
    end
  end
end
