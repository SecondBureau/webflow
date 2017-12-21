$:.push File.expand_path("../lib", __FILE__)

# Maintain your gem's version:
require "webflow/version"

# Describe your gem and declare its dependencies:
Gem::Specification.new do |s|
  s.name        = "webflow"
  s.version     = Webflow::VERSION
  s.authors     = ["Gilles Crofils"]
  s.email       = ["gilles@secondbureau.com"]
  s.homepage    = "https://developers.webflow.com/"
  s.summary     = "Webflow Integration"
  s.description = "Webflow Integration"
  s.license     = "MIT"

  s.files = Dir["{app,config,db,lib}/**/*", "MIT-LICENSE", "Rakefile", "README.md"]

  s.add_dependency 'faraday', '~> 0.13'

  s.add_development_dependency "rails", "~> 5.1.4"
  s.add_development_dependency "sqlite3"
  s.add_development_dependency 'byebug'
end
