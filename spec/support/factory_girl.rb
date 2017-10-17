require 'factory_girl'

RSpec.configure do |c|
  c.include FactoryGirl::Syntax::Methods
end

FactoryGirl.define do
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
end
