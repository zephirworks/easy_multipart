ENV["RAILS_ENV"] = "test"

$:.unshift File.dirname(__FILE__)

require File.join(File.dirname(__FILE__), 'rails_app', 'config', 'environment')
require 'test_help'

ActionMailer::Base.delivery_method = :test
ActionMailer::Base.perform_deliveries = true
ActionMailer::Base.default_url_options[:host] = 'test.com'
