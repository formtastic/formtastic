# encoding: utf-8
require 'spec_helper'

RSpec.describe 'Formtastic::Localizer' do
  describe "Cache" do
    before do
      @cache = Formtastic::Localizer::Cache.new
      @key = ['model', 'name']
      @undefined_key = ['model', 'undefined']
      @cache.set(@key, 'value')
    end
    
    it "should get value" do
      expect(@cache.get(@key)).to eq('value')
      expect(@cache.get(@undefined_key)).to be_nil
    end
    
    it "should check if key exists?" do
      expect(@cache.has_key?(@key)).to be_truthy
      expect(@cache.has_key?(@undefined_key)).to be_falsey
    end
    
    it "should set a key" do
      @cache.set(['model', 'name2'], 'value2')
      expect(@cache.get(['model', 'name2'])).to eq('value2')
    end
    
    it "should return hash" do
      expect(@cache.cache).to be_an_instance_of(Hash)
    end
    
    it "should clear the cache" do
      @cache.clear!
      expect(@cache.get(@key)).to be_nil
    end
  end
  
  describe "Localizer" do
    include FormtasticSpecHelper      
    
    before do
      mock_everything    

      with_config :i18n_lookups_by_default, true do
        semantic_form_for(@new_post) do |builder|
          @localizer = Formtastic::Localizer.new(builder)
        end
      end
    end

    after do
      ::I18n.backend.reload!
    end
    
    it "should be defined" do
      expect { Formtastic::Localizer }.not_to raise_error
    end
    
    it "should have a cache" do
      expect(Formtastic::Localizer.cache).to be_an_instance_of(Formtastic::Localizer::Cache)
    end
    
    describe "localize" do
      def store_post_translations(value)
        ::I18n.backend.store_translations :en, {:formtastic => {
            :labels => {
              :post => { :name => value }
            }
          }
        }        
      end
      
      before do
        store_post_translations('POST.NAME')
      end

      it "should translate key with i18n" do
        expect(@localizer.localize(:name, :name, :label)).to eq('POST.NAME')
      end
      
      describe "with caching" do
        it "should not update translation when stored translations change" do
          with_config :i18n_cache_lookups, true do
            expect(@localizer.localize(:name, :name, :label)).to eq('POST.NAME')
            store_post_translations('POST.NEW_NAME')
            
            expect(@localizer.localize(:name, :name, :label)).to eq('POST.NAME')       
            
            Formtastic::Localizer.cache.clear!
            expect(@localizer.localize(:name, :name, :label)).to eq('POST.NEW_NAME')                  
          end
        end        
      end
      
      describe "without caching" do
        it "should update translation when stored translations change" do
          with_config :i18n_cache_lookups, false do
            expect(@localizer.localize(:name, :name, :label)).to eq('POST.NAME')
            store_post_translations('POST.NEW_NAME')
            expect(@localizer.localize(:name, :name, :label)).to eq('POST.NEW_NAME')            
          end
        end
      end

      describe "with custom resource name" do
        before do
          ::I18n.backend.store_translations :en, {:formtastic => {
              :labels => {
                :post => { :name => 'POST.NAME' },
                :message => { :name => 'MESSAGE.NAME' }
              }
            }
          }

          with_config :i18n_lookups_by_default, true do
            semantic_form_for(@new_post, :as => :message) do |builder|
              @localizer = Formtastic::Localizer.new(builder)
            end
          end
        end

        it "should translate custom key with i18n" do
          expect(@localizer.localize(:name, :name, :label)).to eq('MESSAGE.NAME')
        end
      end 
    end

  end

end
