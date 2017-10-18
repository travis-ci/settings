require "travis/settings/record/#{defined?(Sequel) ? 'sequel' : 'active_record'}"
require 'travis/settings/definition'
require 'travis/settings/group'
require 'travis/settings/lookup'
require 'travis/settings/setting'
require 'travis/settings/store'

module Travis
  module Settings
    class InactiveSetting < StandardError
      def initialize(key, owner)
        super("Setting #{key} not active for owner type=#{owner.class.name} id=#{owner.id}")
      end
    end

    class InvalidValue < StandardError
      def initialize(key, value)
        super("Invalid value for setting #{key}: #{value.inspect}")
      end
    end
  end
end
