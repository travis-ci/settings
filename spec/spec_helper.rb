ENV.delete('DATABASE_URL')
orm = ENV['ORM'] || 'active_record'

require 'settings'
require 'database_cleaner'
require "support/#{orm}"
require 'support/factories'
require 'support/now'

Travis::Encrypt.setup(key: SecureRandom.hex(64))

DatabaseCleaner.clean

RSpec.configure do |c|
  c.include Support::Now
  c.before { DatabaseCleaner.start }
  c.after  { DatabaseCleaner.clean }
end
