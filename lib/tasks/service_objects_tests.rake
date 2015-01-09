Rails::TestTask.new("test:services" => "test:prepare") do |t|
  t.pattern = "test/services/**/*_test.rb"
end

Rake::Task["test:run"].enhance ["test:services"]
