# frozen_string_literal: true
gem 'formtastic', path: '../..'
gem 'bcrypt', '~> 3.1.7'
gem 'rails-dom-testing', group: :test
gem 'rexml', '~> 3.2' # to compensate for missing dependency in selenium-webdriver

in_root do
  ENV['BUNDLE_GEMFILE'] = File.expand_path('Gemfile')
end

formtastic = -> do
  generate(:scaffold, 'user name:string password:digest')
  generate('formtastic:install')
  generate('formtastic:form', 'user name password --force')

  rails_command('db:migrate')

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
