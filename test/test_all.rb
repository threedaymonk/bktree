Dir[ File.join( File.dirname(__FILE__), '*.rb' )].each do |f|
  require f
end
