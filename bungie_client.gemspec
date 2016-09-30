lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'bungie_client/version'

Gem::Specification.new do |spec|
  spec.name          = "bungie_client"
  spec.version       = BungieClient::VERSION
  spec.authors       = ["Dmitry Ruban"]
  spec.email         = ["dkruban@gmail.com"]

  spec.summary       = "This gem makes possible to use Bungie API (and Destiny API too) with authentication if necessary."
  spec.description   = "This gem makes possible to use Bungie API (and Destiny API too) with authentication if necessary. It can be useful, if you decide create your application for Destiny Game (https://www.bungie.net/en/pub/AboutDestiny)."
  spec.homepage      = "https://github.com/RuBAN-GT/bungie_client"
  spec.license       = "MIT"

  spec.files         = `git ls-files -z`.split("\x0").reject { |f| f.match(%r{^(test|spec|features)/}) }
  spec.bindir        = "exe"
  spec.executables   = spec.files.grep(%r{^exe/}) { |f| File.basename(f) }
  spec.require_paths = ["lib"]

  spec.add_development_dependency "bundler", "~> 1.12"
  spec.add_development_dependency "rake", "~> 10.0"
  spec.add_development_dependency "rspec", "~> 3.0"
  spec.add_development_dependency "hashie", "~> 3.4"
  spec.add_development_dependency 'mechanize', "~> 2.7", ">= 2.7.0"
end
