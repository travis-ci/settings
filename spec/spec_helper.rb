orm = ENV['ORM'] || 'active_record'

require 'database_cleaner'
require "support/#{orm}"
require 'support/factory_girl'
require 'support/now'
require 'travis/settings'

DatabaseCleaner.clean

RSpec.configure do |c|
  c.include Support::Now
  c.before { DatabaseCleaner.start }
  c.after  { DatabaseCleaner.clean }
end
