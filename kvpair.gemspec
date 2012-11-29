# -*- encoding: utf-8 -*-
lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'kvpair/version'

Gem::Specification.new do |gem|
  gem.name          = "kvpair"
  gem.version       = KVPair::VERSION
  gem.authors       = ["Kelly Becker"]
  gem.email         = ["kellylsbkr@gmail.com"]
  gem.description   = "Rails easy Key Value Pairs."
  gem.summary       = "Stores namespaced Key Value Pairs."
  gem.homepage      = "http://kellybecker.me"

  gem.files         = `git ls-files`.split($/)
  gem.executables   = gem.files.grep(%r{^bin/}).map{ |f| File.basename(f) }
  gem.test_files    = gem.files.grep(%r{^(test|spec|features)/})
  gem.require_paths = ["lib"]
end
