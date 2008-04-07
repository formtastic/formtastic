desc 'Test the formtastic plugin.'
Rake::TestTask.new(:test) do |t|
  t.libs << 'lib'
  t.pattern = 'test/unit/*_test.rb' # Update this line
  t.verbose = true
end