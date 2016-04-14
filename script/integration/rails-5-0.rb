gsub_file 'test/controllers/users_controller_test.rb', 'get :edit, id: @user', 'get edit_user_url(@user)'

inject_into_class 'app/models/user.rb', 'User', <<-RUBY
  class TokenType < ActiveRecord::Type::String
    def type; :password; end
  end

  attribute :token, TokenType.new
RUBY

inject_into_file 'app/views/users/_form.html.erb', <<-HTML, after: '<%= f.input :password %>'
  <%= f.input :token %>
HTML

inject_into_file 'test/controllers/users_controller_test.rb', <<-RUBY, before: 'end # test "should show form"'
    assert_select 'li#user_token_input.password' do
      assert_select 'input#user_token[type=password]'
    end
RUBY

generate 'migration', 'AddTokenToUsers token:string'
rake 'db:migrate'
