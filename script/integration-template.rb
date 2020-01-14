gem 'formtastic', path: '..'
gem 'bcrypt', '~> 3.1.7'
gem 'rails-dom-testing', group: :test

ENV['BUNDLE_GEMFILE'] = nil
ENV['BUNDLE_FROZEN'] = nil
ENV['BUNDLE_PATH'] = "vendor/bundle"
ENV['BUNDLER_VERSION']= nil
ENV['RUBYOPT'] = nil

run "bundle install"

generate(:scaffold, 'user name:string password:digest')
generate('formtastic:install')
generate('formtastic:form', 'user name password:password --force')

rails_command('db:migrate')

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
