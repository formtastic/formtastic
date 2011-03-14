module Formtastic
  module Inputs
    module NewBase
      module Errors

        def errors?
          !errors.blank?
        end
        
        def errors
          errors = []
          if object && object.respond_to?(:errors)
            error_keys.each do |key| 
              errors << object.errors[key] unless object.errors[key].blank?
            end
          end
          errors.flatten
        end
        
        def error_keys
          keys = [method.to_sym]
          keys << file_metadata_suffixes.map{|suffix| "#{method}_#{suffix}".to_sym} if file?
          keys << association_primary_key if belongs_to?
          keys.flatten.compact.uniq
        end
        
        def error_keys
          keys = [method.to_sym]
          keys << file_metadata_suffixes.map{|suffix| "#{method}_#{suffix}".to_sym} if file?
          keys << [association_primary_key] if belongs_to?
          keys.flatten.compact.uniq
        end

      end
    end
  end
end
        
