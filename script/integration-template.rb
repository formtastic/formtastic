gem 'formtastic', path: '..'
gem 'bcrypt', '~> 3.1.7'

in_root do
  ENV['BUNDLE_GEMFILE'] = File.expand_path('Gemfile')
end

formtastic = -> do
  generate(:scaffold, 'user name:string password_digest:string')
  generate('formtastic:install')

  rake('db:migrate')
end

if respond_to?(:after_bundle) # Rails >= 4.2
  after_bundle(&formtastic)
else # Rails 4.1
  run_bundle
  formtastic.call
end
