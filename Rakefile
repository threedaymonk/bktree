desc "Run all tests"
task :test do
  $:.unshift './test'
  require 'test_all.rb'
end

task :default => :test

desc "Open an irb session preloaded with this library"
task :console do
  sh "irb -Ilib -rbk"
end
