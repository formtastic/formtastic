gem 'formtastic', path: '..'
gem 'bcrypt', '~> 3.1.7'
gem 'rails-dom-testing', group: :test

# to speed up travis install, reuse the bundle path
def bundle_path
  File.expand_path ENV.fetch('BUNDLE_PATH', 'vendor/bundle'), ENV['TRAVIS_BUILD_DIR']
end

if Rails.version >= '6'
    gsub_file 'Gemfile', /gem 'rails'.*/, "gem 'rails', '~> #{Rails.version}', github: 'rails/rails'"
elsif Rails.version >= '5.2'
    gsub_file 'Gemfile', /gem 'rails'.*/, "gem 'rails', '~> #{Rails.version}', github: 'rails/rails', branch: '5-2-stable'"
end

### Ensure Dummy App's Ruby version matches the current environments Ruby Version
ruby_version = "ruby '#{RUBY_VERSION}'"
gsub_file 'Gemfile', /ruby '\d+.\d+.\d+'/, ruby_version

if File.directory?(bundle_path) && bundle_install?
  def run_bundle
    previous_bundle_path = bundle_path

    require "bundler"
    Bundler.with_clean_env do
      system("bundle install --jobs=3 --retry=3 --path=#{previous_bundle_path}")
    end
  end
end

in_root do
  ENV['BUNDLE_GEMFILE'] = File.expand_path('Gemfile')
end

formtastic = -> do
  generate(:scaffold, 'user name:string password:digest')
  generate('formtastic:install')
  generate('formtastic:form', 'user name password:password --force')

  rake('db:migrate')

  in_root do
    inject_into_class 'app/models/user.rb', 'User', "  has_secure_password\n"
    inject_into_file 'app/assets/stylesheets/application.css', " *= require formtastic\n", before: ' *= require_self'
    inject_into_class 'test/controllers/users_controller_test.rb', 'UsersControllerTest', <<-RUBY

    test "should show form" do
      get edit_user_path(@user)

      assert_select 'form' do
        assert_select 'li.input.string' do
          assert_select 'input#user_name[type=text]'
        end
        assert_select 'li.input.password' do
          assert_select 'input#user_password[type=password]'
        end

        assert_select 'fieldset.actions' do
          assert_select 'li.action.input_action' do
            assert_select 'input[type=submit]'
          end
        end
      end
    end # test "should show form"
    RUBY
  end
end

after_bundle(&formtastic)
