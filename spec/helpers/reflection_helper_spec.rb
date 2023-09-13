# encoding: utf-8
# frozen_string_literal: true
require 'spec_helper'

RSpec.describe 'Formtastic::Helpers::Reflection' do

  include FormtasticSpecHelper

  before do
    @output_buffer = ActionView::OutputBuffer.new ''
    mock_everything
  end

  class ReflectionTester
    include Formtastic::Helpers::Reflection
    def initialize(model_object)
      @object = model_object
    end
  end

  context 'with an ActiveRecord object' do
    it "should return association details on an ActiveRecord association" do
      @reflection_tester = ReflectionTester.new(@new_post)
      expect(@reflection_tester.reflection_for(:sub_posts)).not_to be_nil
    end
    it "should return association details on a MongoMapper association" do
      @reflection_tester = ReflectionTester.new(@new_mm_post)
      expect(@reflection_tester.reflection_for(:sub_posts)).not_to be_nil
    end
  end


end