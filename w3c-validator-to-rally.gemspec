Gem::Specification.new do |s|
	s.name			= "w3c-validator-to-rally"
	s.version		= "0.1.0"
	s.description	= "A gem to import W3C errors to Rally"
	s.summary		= "Version 0.1.0"
	s.author		= "Pablo Menezes"
	s.add_dependency 'mechanize', '>= 2.3'
	s.add_dependency 'rally_rest_api','>= 1.0.3'
	s.add_dependency 'logger','>= 1.2.8'
	s.files			= Dir["{lib/**/*.rb,README.rdoc,test/**/*.rb,Rakefile,*.gemspec}"]
end
