# encoding: utf-8

$:.unshift File.expand_path('../lib', __FILE__)

Gem::Specification.new do |s|
  s.name         = "settings"
  s.version      = "0.0.1"
  s.authors      = ["Travis CI"]
  s.email        = "contact@travis-ci.org"
  s.homepage     = "https://github.com/travis-ci/settings"
  s.summary      = "Travis CI Settings"
  s.description  = "#{s.summary}."
  s.license      = "MIT"

  s.files        = Dir['{lib/**/*,spec/**/*,[A-Z]*}']
  s.platform     = Gem::Platform::RUBY
  s.require_path = 'lib'
  s.rubyforge_project = '[none]'

  # s.add_dependency 'travis-encrypt'
end
