require "rake/testtask"

Rake::TestTask.new do |t|
  t.libs << "test"
  t.test_files = FileList["test/**/test_*.rb"]
  t.verbose = true
  t.ruby_opts << "-w"
end

task :default => :test

desc "Open an irb session preloaded with this library"
task :console do
  sh "irb -Ilib -rbk"
end
