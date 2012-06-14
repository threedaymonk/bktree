Dir.glob("test/test_*.rb").each do |file|
  require "./#{file}"
end
