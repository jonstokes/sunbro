# coding: utf-8
lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'sunbro/version'

Gem::Specification.new do |spec|
  spec.name          = "sunbro"
  spec.version       = Sunbro::VERSION
  spec.authors       = ["Jon Stokes"]
  spec.email         = ["jon@jonstokes.com"]
  spec.summary       = %q{Some code that I use to crawl the web at scale. Shared in the spirit of jolly cooperation.}
  spec.description   = %q{Requires phantomjs.}
  spec.homepage      = ""
  spec.license       = "MIT"

  spec.files         = `git ls-files -z`.split("\x0")
  spec.executables   = spec.files.grep(%r{^bin/}) { |f| File.basename(f) }
  spec.test_files    = spec.files.grep(%r{^(test|spec|features)/})
  spec.require_paths = ["lib"]

  spec.add_dependency "nokogiri"
  spec.add_dependency "capybara"
  spec.add_dependency "poltergeist"
  spec.add_dependency "rest-client"
  spec.add_dependency "activesupport"
  spec.add_dependency "hashie"

  spec.add_development_dependency "bundler", "~> 1.5"
  spec.add_development_dependency "rake"
  spec.add_development_dependency "rspec"
  spec.add_development_dependency "mocktra"
end
