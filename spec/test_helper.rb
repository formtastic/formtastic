require 'rubygems'

def smart_require(lib_name, gem_name, gem_version = '>= 0.0.0')
  begin
    require lib_name if lib_name
  rescue LoadError
    if gem_name
      gem gem_name, gem_version
      require lib_name if lib_name
    end
  end
end

smart_require 'spec', 'spec', '>= 1.2.6'
smart_require false, 'rspec-rails', '>= 1.2.6'
smart_require 'hpricot', 'hpricot', '>= 0.6.1'
smart_require 'rspec_hpricot_matchers', 'rspec_hpricot_matchers', '>= 1.0.0'
smart_require 'active_support', 'activesupport', '>= 2.3.4'
smart_require 'action_controller', 'actionpack', '>= 2.3.4'
smart_require 'action_view', 'actionpack', '>= 2.3.4'

Spec::Runner.configure do |config|
  config.include(RspecHpricotMatchers)
end

$LOAD_PATH.unshift(File.join(File.dirname(__FILE__), '..', 'lib'))
