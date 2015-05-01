# coding: utf-8
lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'parole/version'

Gem::Specification.new do |spec|
  spec.name          = 'parole'
  spec.version       = Parole::VERSION
  spec.authors       = ['Rémi Prévost']
  spec.email         = ['rprevost@mirego.com']
  spec.description   = 'Parole adds the ability to comment on ActiveRecord models.'
  spec.summary       = spec.description
  spec.homepage      = 'http://open.mirego.com/parole'
  spec.license       = 'BSD 3-Clause'

  spec.files         = `git ls-files`.split($/)
  spec.executables   = spec.files.grep(%r{^bin/}) { |f| File.basename(f) }
  spec.test_files    = spec.files.grep(%r{^(test|spec|features)/})
  spec.require_paths = ['lib']

  spec.add_development_dependency 'bundler'
  spec.add_development_dependency 'rake'
  spec.add_development_dependency 'sqlite3'
  spec.add_development_dependency 'rspec', '~> 3.2'

  spec.add_dependency 'activerecord', '>= 4.0.0'
  spec.add_dependency 'activesupport', '>= 4.0.0'
end
