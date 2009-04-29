namespace :formtastic do
  
  GEM_ROOT = File.join(File.dirname(__FILE__), '..').freeze
  
  task :setup do
    Rake::Task['formtastic:generate:config'].invoke
    Rake::Task['formtastic:generate:stylesheets'].invoke
  end
  
  namespace :generate do
    
    desc "Generate Formtastic-initializer (configration)."
    task :config do
      config_file = File.join(GEM_ROOT, 'config', 'initializers', 'formtastic.rb')
      to_file = File.join(Rails.root, 'config', 'initializers', 'formtastic.rb')
      
      FileUtils.cp(config_file, to_file)
      
      if File.exist?(to_file)
        puts "[formtastic]: Generated initializer: #{to_file}"
      else
        puts "[formtastic]: ERROR: Failed to generate initializer \"#{File.basename(to_file)}\". Hint: Try with sudo."
      end
    end
    
    desc "Generate Formtastic-stylesheets."
    task :stylesheets do
      stylesheet_files = Dir.glob(File.join(GEM_ROOT, 'public', 'stylesheets', '*.css'))
      to_path = File.join(Rails.public_path, 'stylesheets')
      
      FileUtils.cp(stylesheet_files, to_path)
      
      stylesheet_files.each do |file|
        to_file = File.join(to_path, File.basename(file))
        if File.exist?(to_file)
          puts "[formtastic]: Generated stylesheet: #{to_file}"
        else
          puts "[formtastic]: ERROR: Failed to generate stylesheet \"#{File.basename(file)}\". Hint: Try with sudo."
        end
      end
    end
    
  end
  
end