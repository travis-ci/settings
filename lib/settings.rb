require "settings/record/#{defined?(Sequel) ? 'sequel' : 'active_record'}"
require 'settings/definition'
require 'settings/group'
require 'settings/lookup'
require 'settings/model'
require 'settings/store'

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

  InvalidConfig  = Class.new(StandardError)
  UnknownSetting = Class.new(StandardError)

  def env_vars(owner)
    Record::EnvVar.by_owner(owner)
  end

  def ssh_keys(owner)
    Record::SshKey.where(owner: owner).all
  end

  extend self
end
