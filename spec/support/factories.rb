require 'factory_bot'
require 'securerandom'

RSpec.configure do |c|
  c.include FactoryBot::Syntax::Methods
end

FactoryBot.define do
  to_create { |record| record.save } if defined?(Sequel)

  factory :repo, class: Repository do
    owner_name 'travis-ci'
    name 'travis-hub'
  end

  factory :user do
    login 'user'
  end

  factory :org, class: Organization do
    login 'org'
  end

  factory :owner_group do
    uuid SecureRandom.uuid
  end

  factory :setting, class: Travis::Settings::Record::Setting
end
