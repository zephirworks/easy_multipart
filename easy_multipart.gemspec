lib = File.expand_path('../lib/', __FILE__)
$:.unshift lib unless $:.include?(lib)
 
require 'easy_multipart/version'
 
Gem::Specification.new do |s|
  s.name        = "easy_multipart"
  s.version     = EasyMultipart::VERSION
  s.platform    = Gem::Platform::RUBY
  s.authors     = ["Andrea Campi"]
  s.email       = ["andrea.campi@zephirworks.com"]
  s.homepage    = "http://github.com/zephirworks/easy_multipart"
  s.summary     = "A Ruby gem to send multipart email--the easy way"
 
  s.required_rubygems_version = ">= 1.3.6"
 
  s.files        = Dir.glob("lib/**/*") + %w(LICENSE README.md)
  s.require_path = 'lib'
end
