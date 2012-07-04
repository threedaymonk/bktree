$LOAD_PATH.unshift 'lib'
require "bk/version"

Gem::Specification.new do |s|
  s.name              = "bk"
  s.version           = BK::VERSION
  s.date              = Time.now.strftime('%Y-%m-%d')
  s.summary           = "Burkhard Keller Tree implementation in Ruby"
  s.homepage          = "https://github.com/threedaymonk/bktree"
  s.email             = "pbattley@gmail.com"
  s.authors           = [ "Paul Battley" ]
  s.has_rdoc          = false

  s.files             = %w( README.md Gemfile )
  s.files            += Dir.glob("lib/**/*") + Dir.glob("samples/**/*")
  s.test_files        = Dir.glob("test/**/*")
  s.description       = "Burkhard Keller Tree implementation in Ruby"

  s.add_dependency("text")
  s.add_development_dependency("rake")
end
