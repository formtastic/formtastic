gem 'formtastic', path: '..'
gem 'bcrypt', '~> 3.1.7'
gem 'rails-dom-testing', group: :test

# to speed up travis install, reuse the bundle path
def bundle_path
  File.expand_path ENV.fetch('BUNDLE_PATH', 'vendor/bundle'), ENV['TRAVIS_BUILD_DIR']
end

if File.directory?(bundle_path) && bundle_install?
  def run_bundle
    bundle_command("install --jobs=3 --retry=3 --path=#{bundle_path}")
  end
end

in_root do
  ENV['BUNDLE_GEMFILE'] = File.expand_path('Gemfile')
end

formtastic = -> do
  generate(:scaffold, 'user name:string password_digest:string')
  generate('formtastic:install')
  generate('formtastic:form', 'user name password:password --force')

  rake('db:migrate')

  in_root do
    inject_into_file 'app/models/user.rb', "  has_secure_password\n", after: "< ActiveRecord::Base\n"
    inject_into_file 'app/assets/stylesheets/application.css', " *= require formtastic\n", before: ' *= require_self'
    inject_into_file 'test/controllers/users_controller_test.rb', <<-RUBY, before: '  test "should get edit" do'

    test "should show form" do
      get :edit, id: @user

      assert_select "form" do
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
    end
    RUBY
  end

  script_template = File.expand_path(File.join('integration', 'rails%s.rb'), __dir__)

  scripts = [
      script_template % "-#{Rails::VERSION::MAJOR}-#{Rails::VERSION::MINOR}",
      script_template % "-#{Rails::VERSION::MAJOR}",
      script_template % ''
  ]

  scripts.each do |script|
    if File.exist?(script)
      apply script
    else
      say_status :apply, script, :yellow
    end
  end
end

if respond_to?(:after_bundle) # Rails >= 4.2
  after_bundle(&formtastic)
else # Rails 4.1
  run_bundle
  formtastic.call
end
